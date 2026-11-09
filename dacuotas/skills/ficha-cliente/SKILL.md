---
name: ficha-cliente
description: Ficha de un cliente de Da+Cuotas a partir de su cédula o nombre, identidad y nivel en la app, cupo, KYC, scoring, línea y crédito en Mambu, compras y gestiones de cobranza. Úsala cuando pregunten por una persona concreta. Sólo roles con datos de personas; una persona por consulta.
license: Propietaria. Ver LICENSE.md del repositorio.
metadata:
  version: '1.0.0'
  repositorio: 'https://github.com/Damasco-Vzla/damasco-skills'
---

# Ficha de cliente

Una persona por consulta. Estas consultas quedan registradas con quién las pidió.

## Reglas fijas

1. Cada cifra sale de una llamada hecha en este turno, nunca de memoria ni de un mensaje anterior.
2. Cita `fuente` y `corte_datos` en cada cifra; no mezcles cortes de copias distintas.
3. Traslada tal cual `nota`, `aviso`, `sello`, `avisos_sql` y `aviso_volumen`.
4. Lo que no está en el catálogo (`listar_metricas`) no se responde: declara el límite, nunca un cero. Si una herramienta que pide esta guía no está en tu lista o el MCP responde «herramienta desconocida», tu rol no la tiene: no la reintentes, trabaja con las que tengas y di al usuario en una línea cuál le falta para pedirla a TI.
5. Toda cifra es de apoyo salvo que el `sello` diga `certificada`.
6. Datos de personas sólo de la persona por la que se pregunta; nunca listados.
7. Si el usuario la va a comunicar fuera de su área: «validar con el área dueña y pasar por el Backoffice».
8. Si la misma pregunta se repite o piden «todos los días», usa la skill `de-chat-a-reporte`.

## Pasos

1. `listar_metricas`: comprueba que tu rol tiene `cliente_app`, `buscar_cliente`
   y `detalle_cliente`. Si no las tiene, dilo y para: lo que el rol no ve, no
   existe para ti. No intentes rodearlo con SQL.
2. Normaliza la cédula: sólo dígitos, sin «V-», puntos ni espacios.
3. Orden de llamadas:
   - `cliente_app` con `cedula`: registro, nivel, cupo aprobado y usado,
     scoring, bloqueos y KYC vigente.
   - `buscar_cliente` con `cedula`: el cliente en Mambu y sus créditos.
   - `detalle_cliente` si hace falta el detalle de créditos, cuotas y mora.
   - `cedulas_duplicadas` si aparece más de una coincidencia.
4. Si sólo dan un nombre, `buscar_cliente` con `texto` y un `limite` pequeño;
   si hay varias coincidencias, pide la cédula antes de seguir.
5. Cédula con y sin prefijo: en las copias de Mambu y de la app va sin prefijo;
   en SAP y en el punto de venta de tienda va con `V-` o `E-`. Si tienes que
   cruzar con SQL, normaliza los dos lados (por ejemplo
   `regexp_replace(campo, '[^0-9]', '')`) o usa la columna de cédula
   normalizada que indique `describir_datos`. Un cruce sin normalizar devuelve
   0 filas sin error. Que no aparezca en una fuente NO significa que no sea
   cliente: dilo así.

## Regla de datos personales

- No repitas datos personales más allá de lo preguntado.
- No listes personas por criterios generales (edad, zona, nivel): eso es un
  agregado y va por `como-vamos` o `analisis-libre`, sin datos personales.
- No copies la ficha a resúmenes posteriores de la conversación.
- Bases nominativas o exportaciones: Backoffice o administrador autorizado.

## Cómo entregas la respuesta

Tres bloques, cada uno con su fuente y su corte:

1. Identidad (en la app).
2. Crédito (en Mambu): línea, créditos, mora. La mora es saldo de capital
   pendiente, no la cuota vencida ni el monto original.
3. App: nivel, cupo, scoring, KYC, compras.

Si la persona existe en una fuente y no en la otra, dilo tal cual. Si un dato
no viene, «no consta»; no lo inventes. El diccionario de campos lo da
`describir_datos`, no esta skill.
