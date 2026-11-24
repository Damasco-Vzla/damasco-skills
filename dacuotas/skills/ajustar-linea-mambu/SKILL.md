---
name: ajustar-linea-mambu
description: >-
  Ajusta en Mambu producción el nivel y el monto de la línea a partir de un CSV
  con cédula, nivel y monto. Úsala cuando pidan ejecutar, aplicar o bajar un
  CSV de cédulas contra la línea de Mambu, o cuando nombren ajustar-linea-mambu.
  Primero hace dry run. No escribe hasta que el usuario diga ejecutar.
license: Propietaria. Ver LICENSE.md del repositorio.
metadata:
  version: '1.0.0'
  repositorio: 'https://github.com/Damasco-Vzla/damasco-skills'
---

# Ajustar línea y ficha en Mambu

Corre en Codex de escritorio o en Codex CLI, en la máquina de quien la pide. El API de Kubernetes de producción es privado: ChatGPT en el navegador no puede abrir el túnel. Si la sesión es la web, dilo y para.

El CSV es el destino en Mambu. No reescribas `credit_limits` ni `user_level_progress`. No uses el MCP del DWH: es solo lectura y no es este tenant en vivo.

No uses `POST /mambu/level-mirror/:userId`. Ese camino rechaza un monto menor que lo ya dispuesto. Usa los dos endpoints de abajo.

## CSV

Cabecera exacta: `cedula,nivel,monto`.

```csv
cedula,nivel,monto
V-15548142,1,200
```

`nivel` y `monto` son números. `monto` es el cupo destino, en USD. Normaliza la cédula a `V-` o `E-` más dígitos, como está en `mambu_client_refs.cedula`. Si una fila no trae los tres campos, no la ejecutes y déjala como `fila_invalida`.

## Producción

Solo el tenant `https://damasco.mambu.com`, cluster `damasco-prod`, namespace `damasco`, perfil AWS `dco-prod`, región `us-east-1`. Si `MAMBU_BASE_URL` del pod no empieza por ese host, o el contexto no es `damasco-prod`, para. No uses sandbox, staging ni otro cluster.

La skill no trae llaves. Las lee del entorno del pod. Hace falta `aws`, `session-manager-plugin` y `kubectl`, y un kubeconfig que ya tenga el contexto `damasco-prod`.

1. `aws sso login --profile dco-prod`.
2. Saca el endpoint privado con `aws eks describe-cluster --name damasco-prod --profile dco-prod --region us-east-1`.
3. El salto es la instancia cuyo nombre es `esl-prod-01`. Su id se consulta en el momento; no lo dejes escrito en el chat. Abre el túnel SSM `AWS-StartPortForwardingSessionToRemoteHost` de ese host, puerto 443, al local 16443.
4. Copia el kubeconfig a `/tmp/kubeconfig-tunel-prod.yaml`. En la copia, el server del cluster pasa a `https://127.0.0.1:16443` y `tls-server-name` queda en el host del endpoint, sin `https://`.
5. Elige el pod `bnpl-mambu` que esté Running. El nombre cambia en cada rollout. Antes de leer o escribir:

```bash
KUBECONFIG=/tmp/kubeconfig-tunel-prod.yaml kubectl --context damasco-prod -n damasco \
  exec "$POD" -- node -e 'const u=process.env.MAMBU_BASE_URL||""; if(!u.startsWith("https://damasco.mambu.com")) { console.error("no es prod"); process.exit(1); } console.log("prod");'
```

Base `bnpl-damascuota`. La ref es `mambu_client_refs` (`cedula`, `user_id`, `mambu_client_key`). No uses `nivel` ni `cupo` de esa colección: es una copia vieja.

Ficha de producción, desde el env del pod: set `_Damasco_BNPL`, nivel `BNPL_Nivel`, cupo `BNPL_Limite`. Las lecturas y las escrituras van dentro de ese pod.

## Dry run

Siempre, antes de escribir. Por cada cédula lee la línea viva (`GET /clients/{key}/creditarrangements?detailsLevel=FULL`) y la ficha (`GET /clients/{key}?detailsLevel=FULL`). Entrega una tabla: cédula, cliente, línea, monto actual, disponible, ficha actual, nivel destino, monto destino, y si sube, baja o ya está. Para y pregunta si hay filas que suben el monto. No las ejecutes en el mismo lote que las bajadas salvo que el usuario las confirme aparte.

## Ejecutar

Solo si el usuario dice ejecutar, sobre las filas ya mostradas. Dentro del pod, contra `http://127.0.0.1:$PORT` (el `PORT` del entorno; si falta, 5013), con la cabecera `x-internal-api-key` igual a la variable `INTERNAL_API_KEY` del pod.

1. Si el monto de la línea aprobada o activa difiere del `monto` del CSV, `POST /mambu/credit-arrangements/{caKey}/amount` con `{ "amount": monto, "permitirBajoLoDispuesto": true }`. El permiso hace falta cuando el saldo vivo supera el monto nuevo: Mambu acepta el monto y deja el disponible en negativo. `consumedCreditAmount` llega en 0 con `OUTSTANDING_AMOUNT`; lo dispuesto es `amount - availableCreditAmount`.
2. Sigue solo si la respuesta es 200 y `ca.amount` es el monto pedido. Si no, no escribas la ficha.
3. Si la ficha no tiene ese nivel y ese cupo, `POST /mambu/clients/{clientKey}/risk-line` con `{ "nivel": nivel, "cupo": monto }` y sin `arrangementAmount`.

Dos a la vez, 250 ms entre llamadas. Ante 429 o un cuerpo que diga IP bloqueada, espera 20 s y reintenta una vez. Si se repite, detén el lote. Si el pod se reemplaza, el proceso muere con él; retoma desde el CSV de resultado.

Deja un CSV con `cedula,resultado,linea_antes,linea_despues,ficha_nivel,ficha_cupo`. Resultados: `ya_estaba`, `bajada`, `subida`, `solo_ficha`, `error_linea`, `error_ficha`, `sin_cliente`, `fila_invalida`.
