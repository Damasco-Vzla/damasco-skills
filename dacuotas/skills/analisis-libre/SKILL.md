---
name: analisis-libre
description: Análisis ad hoc con SQL sobre el espejo de Da+Cuotas cuando ninguna herramienta predefinida responde, cruces, cohortes, distribuciones, hipótesis, insights de CredoLab. Úsala ante «calcula», «cruza», «qué porcentaje», «distribución», «compara». Marca cada resultado como cálculo al vuelo.
license: Propietaria. Ver LICENSE.md del repositorio.
metadata:
  version: '1.0.1'
  repositorio: 'https://github.com/Damasco-Vzla/damasco-skills'
---

# Análisis libre

SQL de sólo lectura con `consultar_sql`. Es el último recurso; ni una consulta
propia ni una herramienta predefinida certifican por sí solas una cifra.

## Reglas fijas

1. Cada cifra y corte sale de una llamada hecha en este turno. Una consulta redactada, fallida o sin resultado no es una cifra observada.
2. Cita `fuente`, el corte de cada fuente/objeto (`corte_fuente`, `cortes` u otros campos devueltos), período, moneda/unidad y filtros. No uses el `corte_datos` principal para SAP u otra copia. Fecha de copia y cobertura de negocio son distintas.
3. Conserva `nota`, `aviso`, `sello`, `avisos_sql` y `aviso_volumen` cuando vengan; no inventes campos ausentes. No reproduzcas secretos ni datos personales ajenos al caso.
4. Consulta `listar_metricas` y verifica las herramientas realmente disponibles y su esquema en esta sesión. Catálogo, herramientas expuestas y permisos son distintos: no deduzcas uno del otro. Un catálogo recortado no prueba ausencia; amplía sólo con parámetros reales del esquema o consulta un objeto conocido. Declara límites; nunca los conviertas en cero.
5. Toda cifra es de apoyo salvo que el servidor marque ese resultado concreto como `certificada`. Una herramienta predefinida no certifica por sí sola.
6. Datos de personas sólo para el caso concreto y con acceso permitido; nunca listados ni evasión de permisos con SQL, otra fuente o paginación.
7. Para comunicar fuera del área, validar con el área dueña y pasar por el Backoffice. Las skills no autorizan enviar, publicar, crear tickets ni cambiar datos.
8. Si la pregunta se repite o piden un envío periódico, propone `de-chat-a-reporte`; no crees ni actives el envío por tu cuenta.

## Pasos

1. Antes de SQL, `listar_metricas`. Si existe una herramienta que responde,
   úsala: incluidas `resultado_por_rubro`, `mayor`, `balance_comprobacion`,
   `cxc`, `cxp` y `trazar_documento` para contabilidad (skill `finanzas-sap`),
   y `analisis_vigente` para el seguimiento diario, cuando estén expuestas.
   Si el catálogo anuncia una herramienta que no está en esta sesión, declara
   esa diferencia. SQL sólo puede suplirla si está autorizado y el diccionario
   expone el objeto; nunca para rodear una denegación de acceso.
2. `describir_datos` del objeto antes de escribir. El catálogo de métricas
   no es un inventario completo de objetos: permite un análisis ad hoc si el
   diccionario y el acceso lo autorizan. Los nombres de vista y columna no se
   adivinan. Si el diccionario está recortado, consulta el objeto conocido;
   no inventes parámetros de búsqueda o paginación que el esquema no expone.
3. Reglas de SQL (Athena, dialecto Trino):
   - Una sola sentencia `SELECT` o `WITH`, sin punto y coma ni comentarios,
     usando únicamente los objetos permitidos por el esquema vigente.
   - Filtra por período y agrupa en la consulta; nunca traigas detalle para
     sumar fuera.
   - `LIMIT` siempre. El tope de filas lo pone tu rol; si necesitas más,
     resume en la consulta.
   - Para el período usa fechas de negocio. Las vistas pueden fijar el corte;
     las tablas crudas pueden requerir filtrar su partición. Sigue lo que
     indique `describir_datos` para ese objeto, sin mezclar cargas duplicadas
     ni convertir la fecha de carga en fecha de negocio.
   - Un 400 puede ser sintaxis, columna o una restricción. Corrige sólo errores
     corregibles con el esquema; ante denegación, detente. No ocultes un fallo
     persistente ni cambies de fuente para saltarte permisos.
   - Un 504 no trae un resultado terminado. Si el servidor indica explícitamente
     cómo recuperar o reutilizar una ejecución en curso, sigue ese mecanismo
     y su espera, sin lanzar trabajos duplicados. Si no, acota período o
     granularidad y explica el cambio de alcance; no repitas a ciegas.
   - Antes de un `JOIN`, define la granularidad y verifica unicidad de claves.
     Agrega el lado múltiple para no duplicar importes; no lo tapes con DISTINCT.
4. Lee y traslada la respuesta:
   - Usa el resultado recibido, no la SQL que planeabas ejecutar. Distingue
     la SQL enviada de `sql_ejecutada` si el servidor la devuelve.
   - Comparte la SQL sólo en el formato permitido por el cliente y sin
     identificadores personales, secretos ni literales de otros casos. Si
     ocultas valores, etiqueta la copia como anonimizada, no como SQL exacta.
   - `nota`, `avisos_sql` (fecha contable, tasa propia, mezcla de sociedades:
     avisan, no bloquean), `aviso_volumen`, `columnas_pii`, `sello`.
   - Si vienen 0 filas, revisa cobertura, filtros, nota y posibles recortes.
     Una respuesta vacía, NULL, acceso denegado y un cero observado son distintos.
   - No presentes un total sumando filas truncadas. Si calculas ratios, conserva
     numerador y denominador, controla denominador cero y cuenta claves únicas.
5. Si la misma llamada falla dos veces, cámbiala o pregunta al usuario: el
   servidor frena la repetición.
6. Moneda: verifica la unidad de cada campo; no asumas USD por el nombre de la
   tabla ni que moneda de sistema significa USD. SAP puede traer moneda local
   y de sistema. No conviertas salvo petición expresa; documenta tasa, fecha,
   fuente y sentido de conversión y marca el resultado como `escenario`.

## Referencias

- `references/trampas-sql.md`: las trampas que más cifras falsas han dado.
- `references/recetas-credolab.md`: cómo leer los insights de CredoLab
  (score nativo, PD, alertas de fraude, apps de riesgo).
- `references/fuentes-externas.md`: Cashea u otra fuente cuyo período vigente
  depende de un Excel; cobertura, solapamientos y conciliación sin atribuirlo al MCP.

## Cómo entregas la respuesta

Cifra observada, fuente, corte por fuente, período, moneda, filtros, SQL
(con las cautelas anteriores) y esta línea: «Cálculo al vuelo; validar
con el área dueña antes de comunicar». Nunca la presentes como métrica
verificada.
