# Insights de CredoLab

Cuando pregunten qué dijo CredoLab de una persona o de un día: score nativo,
probabilidad de impago (PD), alertas de fraude, apps de riesgo, dispositivo,
velocity o cobertura de los insights. Sólo lectura del espejo: nunca se vuelve
a llamar a CredoLab.

Para la banda y el cupo basta con `cliente_app` y `scoring_app`; esto es para
lo que esas herramientas no traen.

## Antes de escribir

1. `listar_metricas` y `describir_datos`: la vista de resultados de scoring, la
   de referencias de CredoLab y la de verificaciones KYC, con sus columnas.
2. Una persona: la cédula en la forma que diga `describir_datos` para la vista
   de referencias. Agregados: siempre con ventana de fechas; la columna de
   insights pesa mucho y una consulta sin ventana no cabe en el tope.

## Forma del JSON de insights

Texto JSON con un arreglo `insights`; cada elemento tiene `code` y `value`.
Códigos: `score` (`value.score`, `value.probability`), `fraudAlerts` (mapa
alerta a `low`/`medium`/`high`), `riskyApps` (mapa flag a `"0"`/`"1"`),
`deviceInfo` y `velocity`. No todas las filas traen todos los códigos: usa
`element_at(..., 1)`, no `[1]`.

```sql
WITH s AS (
  SELECT CAST(json_extract(<columna_insights>, '$.insights') AS ARRAY(JSON)) AS ins
  FROM <vista_scoring>
  WHERE <filtro_de_persona_o_ventana_de_fechas>
)
SELECT
  json_extract_scalar(element_at(filter(ins, x -> json_extract_scalar(x, '$.code') = 'score'), 1),
                      '$.value.score')       AS score_nativo,
  json_extract_scalar(element_at(filter(ins, x -> json_extract_scalar(x, '$.code') = 'score'), 1),
                      '$.value.probability') AS pd,
  array_join(map_keys(map_filter(
    CAST(json_extract(element_at(filter(ins, x -> json_extract_scalar(x, '$.code') = 'fraudAlerts'), 1),
                      '$.value') AS MAP(VARCHAR, VARCHAR)),
    (k, v) -> v IN ('high', 'medium'))), ', ') AS alertas,
  array_join(map_keys(map_filter(
    CAST(json_extract(element_at(filter(ins, x -> json_extract_scalar(x, '$.code') = 'riskyApps'), 1),
                      '$.value') AS MAP(VARCHAR, VARCHAR)),
    (k, v) -> v = '1')), ', ') AS apps_de_riesgo
FROM s
LIMIT 10
```

Sustituye los marcadores `<...>` con lo que diga `describir_datos`. Para
agregados por día, agrupa por el día en hora de Venezuela (ver
`trampas-sql.md`) y usa `count_if` sobre el estado de los insights.

## Cómo leer el resultado

- Estado de los insights: `ok` hay datos; `missing` no había dataset; `error`
  fallo de red o de lectura; vacío es una evaluación que no pasó por CredoLab,
  no «CredoLab vacío».
- Score nativo y PD son de CredoLab (PD más baja es mejor). La banda y el
  score compuesto son del motor propio, que sí mueve el cupo. Los insights no
  cambian la banda: no los presentes como si lo hicieran.
- Score 0 con banda de rechazo o decisión ponderada: casi siempre no hubo
  dataset usable, no un cliente malo. Compara la referencia subida con la
  usada.
- La alerta de geografía sale alta en casi todos por VPN y geolocalización:
  dilo y no la cuentes como señal por sí sola. Emulador, granja de
  dispositivos y acceso remoto sí lo son.
- Dispositivo y velocity son contraste, no prueba de identidad.

## Lo que no haces

- Llamar a CredoLab, rehidratar o escribir.
- Listar apps instaladas, selfies, hashes ni JSON crudo.
- Inventar una cobertura si la consulta falla o vuelve recortada.
- Consultas sobre los insights sin ventana de fechas.
