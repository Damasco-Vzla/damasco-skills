---
name: como-vamos
description: Foto del negocio Da+Cuotas, cómo vamos hoy, cartera, mora, colocación, cobranza, recaudo, call center, cupos, usuarios y compras de la app. Úsala ante «cómo vamos», «resumen», «dame el panorama», «cómo cerró ayer» o cualquier pregunta de seguimiento diario. No para una persona concreta ni para contabilidad de SAP.
license: Propietaria. Ver LICENSE.md del repositorio.
metadata:
  version: '1.0.1'
  repositorio: 'https://github.com/Damasco-Vzla/damasco-skills'
---

# Cómo vamos

Foto del negocio con cifras del MCP `dwh-dacuotas`. Explorar con el MCP, operar
con el Backoffice, validar siempre con criterio humano.

## Reglas fijas

1. Cada cifra y corte sale de una llamada hecha en este turno. Una consulta redactada, fallida o sin resultado no es una cifra observada.
2. Cita `fuente`, el corte de cada fuente/objeto (`corte_fuente`, `cortes` u otros campos devueltos), período, moneda/unidad y filtros. No uses el `corte_datos` principal para SAP u otra copia. Fecha de copia y cobertura de negocio son distintas.
3. Conserva `nota`, `aviso`, `sello`, `avisos_sql` y `aviso_volumen` cuando vengan; no inventes campos ausentes. No reproduzcas secretos ni datos personales ajenos al caso.
4. Consulta `listar_metricas` y verifica las herramientas realmente disponibles y su esquema en esta sesión. Catálogo, herramientas expuestas y permisos son distintos: no deduzcas uno del otro. Un catálogo recortado no prueba ausencia; amplía sólo con parámetros reales del esquema o consulta un objeto conocido. Declara límites; nunca los conviertas en cero.
5. Toda cifra es de apoyo salvo que el servidor marque ese resultado concreto como `certificada`. Una herramienta predefinida no certifica por sí sola.
6. Datos de personas sólo para el caso concreto y con acceso permitido; nunca listados ni evasión de permisos con SQL, otra fuente o paginación.
7. Para comunicar fuera del área, validar con el área dueña y pasar por el Backoffice. Las skills no autorizan enviar, publicar, crear tickets ni cambiar datos.
8. Si la pregunta se repite o piden un envío periódico, propone `de-chat-a-reporte`; no crees ni actives el envío por tu cuenta.

## Antes de llamar

Traduce «hoy», «ayer», «esta semana» y «el mes pasado» desde la fecha real en
`America/Caracas` (UTC-4), no desde el corte. Explicita las fechas AAAA-MM-DD.
Si el corte no alcanza el período pedido, señala la cobertura parcial; no
rebautices la última foto como «hoy» ni un día abierto como cierre completo.

Para «¿cómo vamos?» puedes usar el resumen general al último corte, indicando
su alcance y moneda sin interrogar al usuario. Pregunta en una sola línea sólo
lo que cambie la respuesta (por ejemplo, ventas BNPL frente a ventas de SAP).
Para semanas, declara el inicio elegido; compara períodos de igual duración
y madurez, o advierte que uno sigue abierto.

## Pasos

1. `listar_metricas` primero: lee definiciones, unidades y limitaciones. Revisa
   si hay recorte y contrasta con las herramientas expuestas; no infieras
   permisos sólo por presencia o ausencia de una métrica.
2. Si está expuesta y su esquema lo admite, usa `analisis_vigente` con
   `analisis: "cartera_diaria"`. Lee qué secciones devolvió antes de afirmar
   que incluye todas las fuentes. No vuelvas a consultar cifras ya devueltas.
   Si no está disponible en esta sesión, usa `resumen` para crédito y, sólo
   si aporta al pedido, `resumen_app` o las herramientas por métrica. Aclara
   qué no cubre ese resumen; no simules el análisis precalculado.
3. «Qué se movió desde ayer» o desde una respuesta anterior: `cambios_desde`.
   Para las filas completas de una sección: `detalle_analisis`, sólo si ambas
   herramientas están disponibles y con los parámetros de su esquema. Si no,
   compara consultas nuevas de períodos con cobertura comprobada. Una foto
   actual no reconstruye la cartera de ayer.
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
- Cashea u otra financiera externa con la cartera propia. Que existan tablas
  históricas no demuestra que esté cargado el dato actual: confirma cobertura
  y fuente vigente. Si el análisis depende de un Excel externo, solicita el
  archivo autorizado y su corte; no presentes el histórico como dato actual.

Si el cruce no está resuelto por una herramienta, puede evaluarse con
`analisis-libre` sólo si el diccionario y el acceso lo permiten. No aproximar
uniones ni confundir dominios para cubrir un dato faltante.

## Cómo entregas la respuesta

- Titular con la cifra, su fuente y su corte («según la copia de las HH:MM UTC»).
  Usa el corte específico de esa fuente tal cual viene.
- Tres variaciones relevantes como mucho.
- Los límites que declaró el servidor (`nota`, `aviso`).
- La mora es saldo de capital pendiente de los créditos atrasados, no cuota vencida.
- Sin tablas de más de diez filas; si hay más, resume y ofrece el detalle.
- Si la respuesta indica recorte (`filas_recortadas` u otro aviso), no sumes
  esas filas como un total: pide un agregado completo a la fuente.
- Un 504 es una consulta demasiado grande: acota el período o agrupa menos fino.
- Si la misma foto se pide a diario, propone `de-chat-a-reporte` sin negar la
  consulta actual. Crear el reporte o activar el envío requiere autorización.
