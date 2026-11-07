---
name: ficha-cliente
description: Ficha de un cliente de Da+Cuotas a partir de su cédula o nombre, identidad y nivel en la app, cupo, KYC, scoring, línea y crédito en Mambu, compras y gestiones de cobranza. Úsala cuando pregunten por una persona concreta. Sólo roles con datos de personas; una persona por consulta.
license: Propietaria. Ver LICENSE.md del repositorio.
metadata:
  version: '1.0.1'
  repositorio: 'https://github.com/Damasco-Vzla/damasco-skills'
---

# Ficha de cliente

Una persona por consulta. Consulta sólo las fuentes necesarias para la pregunta.

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

1. `listar_metricas` y herramientas disponibles: comprueba el acceso a la
   fuente necesaria. Si falta una, ofrece sólo la parte accesible y señala
   el límite; no afirmes que el cliente no existe ni lo rodees con SQL.
2. Usa el formato de identificación que acepte el esquema de la herramienta.
   Conserva el tipo V/E cuando lo tengas; no unas personas distintas sólo
   porque coinciden sus dígitos ni normalices RIF como cédula.
3. Según lo preguntado, usa:
   - `cliente_app` con `cedula`: campos de la app que devuelva, sin asumir que
     siempre incluye cupo usado, bloqueos, compras o KYC vigente.
   - `buscar_cliente` con `cedula`: ficha y resumen que devuelva de Mambu.
   - `detalle_cliente` si hace falta el detalle de créditos, cuotas y mora.
   - Si hay varias fichas para esa cédula, informa la ambigüedad del caso.
     No llames a `cedulas_duplicadas`: devuelve un listado global, no filtra
     esta persona. No traigas otras identidades para resolver la duda.
4. Si sólo dan un nombre, `buscar_cliente` con `texto` y un `limite` pequeño;
   si hay varias coincidencias, pide la cédula antes de seguir, sin publicar
   las fichas de los candidatos.
5. Cédula con y sin prefijo: en las copias de Mambu y de la app va sin prefijo;
   en SAP y en el punto de venta de tienda va con `V-` o `E-`. Si tienes que
   cruzar con SQL, normaliza los dos lados (por ejemplo
   `regexp_replace(campo, '[^0-9]', '')`) o usa la columna de cédula
   normalizada que indique `describir_datos`. Excluye RIF de empresas,
   comprueba el tipo de documento y la unicidad antes de unir. Una coincidencia
   sólo numérica sin tipo verificable no prueba identidad. Un cruce sin normalizar devuelve
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

Devuelve sólo los bloques necesarios. Distingue «no consta en esta fuente» de
«no consultado», «sin acceso» y «consulta fallida». Si un dato
no viene, no lo inventes. El diccionario de campos lo da
`describir_datos`, no esta skill.
