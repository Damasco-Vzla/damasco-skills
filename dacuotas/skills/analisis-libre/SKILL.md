---
name: analisis-libre
description: Análisis ad hoc con SQL sobre el espejo de Da+Cuotas cuando ninguna herramienta predefinida responde, cruces, cohortes, distribuciones, hipótesis, insights de CredoLab. Úsala ante «calcula», «cruza», «qué porcentaje», «distribución», «compara». Marca cada resultado como cálculo al vuelo.
license: Propietaria. Ver LICENSE.md del repositorio.
metadata:
  version: '1.0.0'
  repositorio: 'https://github.com/Damasco-Vzla/damasco-skills'
---

# Análisis libre

SQL de sólo lectura con `consultar_sql`. Es el último recurso: las cifras de las
herramientas predefinidas están verificadas y las tuyas no.

## Reglas fijas

1. Cada cifra sale de una llamada hecha en este turno, nunca de memoria ni de un mensaje anterior.
2. Cita `fuente` y `corte_datos` en cada cifra; no mezcles cortes de copias distintas.
3. Traslada tal cual `nota`, `aviso`, `sello`, `avisos_sql` y `aviso_volumen`.
4. Lo que no está en el catálogo (`listar_metricas`) no se responde: declara el límite, nunca un cero.
5. Toda cifra es de apoyo salvo que el `sello` diga `certificada`.
6. Datos de personas sólo de la persona por la que se pregunta; nunca listados.
7. Si el usuario la va a comunicar fuera de su área: «validar con el área dueña y pasar por el Backoffice».
8. Si la misma pregunta se repite o piden «todos los días», usa la skill `de-chat-a-reporte`.

## Pasos

1. Antes de SQL, `listar_metricas`. Si existe una herramienta que responde,
   úsala: incluidas `resultado_por_rubro`, `mayor`, `balance_comprobacion`,
   `cxc`, `cxp` y `trazar_documento` para contabilidad (skill `finanzas-sap`),
   y `analisis_vigente` para el seguimiento diario.
2. `describir_datos` del objeto antes de escribir. Los nombres de vista y de
   columna no se adivinan.
3. Reglas de SQL (Athena, dialecto Trino):
   - Filtra por período y agrupa en la consulta; nunca traigas detalle para
     sumar fuera.
   - `LIMIT` siempre. El tope de filas lo pone tu rol; si necesitas más,
     resume en la consulta.
   - No filtres por la partición técnica de carga: usa las fechas de negocio
     que indique `describir_datos`.
   - Un 400 trae el error con línea y columna: corrige y reintenta sin
     contárselo al usuario.
   - Un 504 es una consulta demasiado grande: acota el período, agrupa menos
     fino o parte el cálculo.
4. Lee y traslada la respuesta:
   - `sql_ejecutada`: muéstrala al dar la cifra, en un bloque de código.
   - `nota`, `avisos_sql` (fecha contable, tasa propia, mezcla de sociedades:
     avisan, no bloquean), `aviso_volumen`, `columnas_pii`, `sello`.
   - Si vienen 0 filas, aplica la nota del servidor (formato de cédula, carril
     en reconstrucción) antes de concluir «no hay».
5. Si la misma llamada falla dos veces, cámbiala o pregunta al usuario: el
   servidor frena la repetición.
6. Moneda: SAP trae moneda local y moneda de sistema en cada línea. No
   conviertas con una tasa propia salvo que el usuario lo pida; entonces el
   resultado es un `escenario` y lo dices.

## Referencias

- `references/trampas-sql.md`: las trampas que más cifras falsas han dado.
- `references/recetas-credolab.md`: cómo leer los insights de CredoLab
  (score nativo, PD, alertas de fraude, apps de riesgo).

## Cómo entregas la respuesta

Cifra, fuente, corte, la SQL ejecutada y esta línea: «Cálculo al vuelo; validar
con el área dueña antes de comunicar». Nunca la presentes como métrica
verificada.
