# Trampas de SQL en el espejo

Cada una ha dado alguna vez una cifra falsa sin ningún error. Los nombres de
vistas y columnas los da `describir_datos`; aquí sólo el patrón.

## Cédula con y sin prefijo

Las copias de Mambu y de la app guardan la cédula sin prefijo. SAP y el punto
de venta de tienda la guardan con `V-` o `E-`, y también guardan RIF de empresa
con `J-`. Un JOIN directo devuelve 0 filas sin error.

```sql
ON regexp_replace(a.cedula, '[^0-9]', '') = regexp_replace(b.cedula_con_prefijo, '[^0-9]', '')
WHERE (b.cedula_con_prefijo LIKE 'V-%' OR b.cedula_con_prefijo LIKE 'E-%')
```

Este fragmento es un patrón, no SQL ejecutable sin diccionario. Encierra el
filtro V/E entre paréntesis si añades otras condiciones con AND. Excluir J no
basta para probar identidad: conserva y verifica el tipo V/E cuando exista,
rechaza claves vacías y comprueba duplicados en ambos lados antes del JOIN.
Si falta el tipo, informa la incertidumbre, no certifiques una unión por dígitos.
Los cruces son parciales: indica cuántas claves casaron y cuántas no, sin PII.

## Zona horaria

Verifica tipo y zona en `describir_datos`; no toda columna es un timestamp UTC.
Para texto ISO-8601 con zona, «el día» en Venezuela puede calcularse así:

```sql
DATE(at_timezone(from_iso8601_timestamp(creado_en), 'America/Caracas'))
```

Un día contado en UTC mueve cuatro horas de un día al siguiente.
No apliques `from_iso8601_timestamp` a una columna que ya es timestamp ni
conviertas una fecha contable DATE. Usa intervalos de inicio incluido y fin
excluido para timestamps, respetando el contrato de cada herramienta.

## Partición técnica de carga

Las vistas de negocio ya están al último corte. No filtres por la partición
técnica de carga ni uses su máximo: usa las fechas de negocio. Esto no vale
para todas las bases: si `describir_datos` dice que una tabla necesita fijar el
corte, hazlo como indica.

## Texto que parece número

Muchas columnas de copias crudas son texto. Usa `TRY_CAST` y compara con
`NULL`: un `CAST` falla y un campo vacío no es un cero. Las pocas columnas
enteras se comparan sin comillas; con comillas dan `TYPE_MISMATCH`.

## 504

No hay resultado terminado. Si la respuesta explica cómo recuperar o reutilizar
una ejecución en curso, respeta ese mecanismo y su espera sin lanzar trabajos
duplicados. Si no, acota período o granularidad. No repitas a ciegas ni presentes
una estimación como resultado. Tras dos fallos, cambia el plan o declara el límite.

## Mezcla de sociedades

SAP Productiva e Importadora son contabilidades distintas: no se suman. Una
sociedad por consulta. `avisos_sql` avisa si la consulta mezcla.

## Fecha contable y fecha de creación

En contabilidad manda la fecha contable del asiento, no la de creación del
documento. `avisos_sql` avisa si filtras por la segunda.

## Moneda

En SAP el importe de línea viene en moneda local y en moneda de sistema. La
columna de moneda del documento no cambia en qué moneda está el importe. No
supongas el código de moneda; confírmalo. No apliques tasas propias salvo que
el usuario lo pida: el resultado sería un `escenario`, con tasa, fecha,
fuente y sentido de conversión.

## Granularidad y resultados incompletos

Un JOIN de cabeceras con líneas o pagos puede multiplicar saldos. Define qué
representa cada fila, prueba unicidad y agrega el lado múltiple antes de unir.
No arregles multiplicaciones con DISTINCT sobre importes. No sumes páginas
truncadas como un total. Distingue cero observado, NULL, sin filas y fallo;
un ratio con denominador cero es no calculable, no 0 %.

## Fuentes que no se suman

- Gestiones y promesas del call center no son dinero cobrado.
- Cupo de la app no es cartera de Mambu.
- Pedidos de la app no son desembolsos.
- La financiera externa no es cartera propia.

Para Cashea, verifica si el dato solicitado es histórico disponible o depende
del Excel externo vigente. Tablas en el catálogo no garantizan carga actual.
No inventes un corte; si falta el archivo autorizado, declara esa dependencia.

## Períodos con carga atípica

Hay meses con carga atípica (migraciones de cartera) que no son captación
orgánica. El servidor lo avisa en `nota` y `listar_metricas` lo trae en sus
limitaciones: trasládalo al comparar períodos. Antes del inicio de una copia no
hay dato: «no está disponible», nunca un cero.
