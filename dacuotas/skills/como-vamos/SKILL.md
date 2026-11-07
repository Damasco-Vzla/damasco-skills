---
name: como-vamos
description: Foto del negocio Da+Cuotas, cómo vamos hoy, cartera, mora, colocación, cobranza, recaudo, call center, cupos, usuarios y compras de la app. Úsala ante «cómo vamos», «resumen», «dame el panorama», «cómo cerró ayer» o cualquier pregunta de seguimiento diario. No para una persona concreta ni para contabilidad de SAP.
license: Propietaria. Ver LICENSE.md del repositorio.
metadata:
  version: '1.0.0'
  repositorio: 'https://github.com/Damasco-Vzla/damasco-skills'
---

# Cómo vamos

Foto del negocio con cifras del MCP `dwh-dacuotas`. Explorar con el MCP, operar
con el Backoffice, validar siempre con criterio humano.

## Reglas fijas

1. Cada cifra sale de una llamada hecha en este turno, nunca de memoria ni de un mensaje anterior.
2. Cita `fuente` y `corte_datos` en cada cifra; no mezcles cortes de copias distintas.
3. Traslada tal cual `nota`, `aviso`, `sello`, `avisos_sql` y `aviso_volumen`.
4. Lo que no está en el catálogo (`listar_metricas`) no se responde: declara el límite, nunca un cero.
5. Toda cifra es de apoyo salvo que el `sello` diga `certificada`.
6. Datos de personas sólo de la persona por la que se pregunta; nunca listados.
7. Si el usuario la va a comunicar fuera de su área: «validar con el área dueña y pasar por el Backoffice».
8. Si la misma pregunta se repite o piden «todos los días», usa la skill `de-chat-a-reporte`.

## Antes de llamar

Si el usuario no fijó objetivo, perímetro (canal, tienda), período y moneda,
pregúntalo en una sola línea. Traduce «ayer», «esta semana», «el mes pasado» a
fechas AAAA-MM-DD en hora de Venezuela (UTC-4). «Hoy» para estos datos es el
día del corte; dilo si no coincide con la fecha real.

## Pasos

1. `listar_metricas` primero: dice qué puede ver tu rol, qué significa cada
   cifra y qué no se puede responder.
2. Seguimiento diario: `analisis_vigente` con `analisis: "cartera_diaria"`. Ya
   trae resumen, mora por tramo, cobranza, colocación, recaudo, call center,
   cupos y serie de mora del corte vigente sin volver a escanear. No repitas
   `cartera`, `mora` o `cobranza` por separado para lo mismo.
3. «Qué se movió desde ayer» o desde una respuesta anterior: `cambios_desde`.
   Para las filas completas de una sección: `detalle_analisis`.
4. Sólo si el usuario pide un corte o desglose que el análisis no trae, usa la
   herramienta por métrica: `resumen`, `cartera`, `mora`, `cobranza`,
   `recaudo`, `colocacion`, `comisiones`, `ingresos`, `serie`, `embudo`,
   `clientes`, `resumen_app`, `usuarios_app`, `registros_app`, `cupos_app`,
   `compras_app`, `productos_comprados_app`, `gestion_callcenter`.
5. Para comparar dos períodos, dos llamadas y compara tú.

## Qué no se cruza

No sumes ni compares como si fueran lo mismo:

- Gestiones o promesas del call center con dinero cobrado (lo cobrado es `cobranza`).
- Cupo de la app con cartera de Mambu.
- Pedidos de la app con desembolsos del crédito.
- SAP Productiva con SAP Importadora.

Si el cruce que piden no existe en el catálogo, dilo en vez de aproximarlo.

## Cómo entregas la respuesta

- Titular con la cifra, su fuente y su corte («según la copia de las HH:MM UTC»).
  Usa `corte_datos` tal cual viene.
- Tres variaciones relevantes como mucho.
- Los límites que declaró el servidor (`nota`, `aviso`).
- La mora es saldo de capital pendiente de los créditos atrasados, no cuota vencida.
- Sin tablas de más de diez filas; si hay más, resume y ofrece el detalle.
- Si `filas_recortadas` viene en la respuesta, di que no vino entera y pide un agregado.
- Un 504 es una consulta demasiado grande: acota el período o agrupa menos fino.
- Si la misma foto se pide a diario, remite a `de-chat-a-reporte`: eso es un
  reporte del Backoffice o un envío programado, no un chat.
