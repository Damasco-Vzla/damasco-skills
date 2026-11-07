# Trampas de SQL en el espejo

Cada una ha dado alguna vez una cifra falsa sin ningún error. Los nombres de
vistas y columnas los da `describir_datos`; aquí sólo el patrón.

## Cédula con y sin prefijo

Las copias de Mambu y de la app guardan la cédula sin prefijo. SAP y el punto
de venta de tienda la guardan con `V-` o `E-`, y también guardan RIF de empresa
con `J-`. Un JOIN directo devuelve 0 filas sin error.

```sql
ON regexp_replace(a.cedula, '[^0-9]', '') = regexp_replace(b.cedula_con_prefijo, '[^0-9]', '')
WHERE b.cedula_con_prefijo LIKE 'V-%' OR b.cedula_con_prefijo LIKE 'E-%'
```

El filtro de prefijo no es opcional: el número de un RIF puede coincidir con
la cédula de otra persona. Los cruces por cédula son parciales: di siempre qué
parte de la cartera casó.

## Zona horaria

Las marcas de tiempo vienen en UTC. Para «el día» en Venezuela:

```sql
DATE(at_timezone(from_iso8601_timestamp(creado_en), 'America/Caracas'))
```

Un día contado en UTC mueve cuatro horas de un día al siguiente.

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

La consulta tardó demasiado o escaneó demasiado. Acota el período, agrupa menos
fino o parte el cálculo en dos. No reintentes la misma consulta.

## Mezcla de sociedades

SAP Productiva e Importadora son contabilidades distintas: no se suman. Una
sociedad por consulta. `avisos_sql` avisa si la consulta mezcla.

## Fecha contable y fecha de creación

En contabilidad manda la fecha contable del asiento, no la de creación del
documento. `avisos_sql` avisa si filtras por la segunda.

## Moneda

En SAP el importe de línea viene en moneda local y en moneda de sistema. La
columna de moneda del documento no cambia en qué moneda está el importe. No
apliques tasas propias sin decirlo: el resultado sería un `escenario`.

## Fuentes que no se suman

- Gestiones y promesas del call center no son dinero cobrado.
- Cupo de la app no es cartera de Mambu.
- Pedidos de la app no son desembolsos.
- La financiera externa no es cartera propia.

## Períodos con carga atípica

Hay meses con carga atípica (migraciones de cartera) que no son captación
orgánica. El servidor lo avisa en `nota` y `listar_metricas` lo trae en sus
limitaciones: trasládalo al comparar períodos. Antes del inicio de una copia no
hay dato: «no está disponible», nunca un cero.
