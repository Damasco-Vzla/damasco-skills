---
name: de-chat-a-reporte
description: Convierte una pregunta repetida del MCP de Da+Cuotas en un pedido de reporte del Backoffice o envío programado, redacta el ticket de Linear con objetivo, fuente, métrica, período, moneda, cortes, frecuencia y responsable de validar. Úsala cuando el usuario repita una consulta, diga «todos los días», «mándame», «exporta», «pásame la base» o cuando una respuesta traiga aviso de consulta recurrente.
license: Propietaria. Ver LICENSE.md del repositorio.
metadata:
  version: '1.0.1'
  repositorio: 'https://github.com/Damasco-Vzla/damasco-skills'
---

# De chat a reporte

El MCP sirve para explorar. Propón trasladar lo recurrente al Backoffice sin
negar una consulta puntual nueva que el usuario necesita ahora.

## Reglas fijas

1. Cada cifra y corte sale de una llamada hecha en este turno. Una consulta redactada, fallida o sin resultado no es una cifra observada.
2. Cita `fuente`, el corte de cada fuente/objeto (`corte_fuente`, `cortes` u otros campos devueltos), período, moneda/unidad y filtros. No uses el `corte_datos` principal para SAP u otra copia. Fecha de copia y cobertura de negocio son distintas.
3. Conserva `nota`, `aviso`, `sello`, `avisos_sql` y `aviso_volumen` cuando vengan; no inventes campos ausentes. No reproduzcas secretos ni datos personales ajenos al caso.
4. Consulta `listar_metricas` y verifica las herramientas realmente disponibles y su esquema en esta sesión. Catálogo, herramientas expuestas y permisos son distintos: no deduzcas uno del otro. Un catálogo recortado no prueba ausencia; amplía sólo con parámetros reales del esquema o consulta un objeto conocido. Declara límites; nunca los conviertas en cero.
5. Toda cifra es de apoyo salvo que el servidor marque ese resultado concreto como `certificada`. Una herramienta predefinida no certifica por sí sola.
6. Datos de personas sólo para el caso concreto y con acceso permitido; nunca listados ni evasión de permisos con SQL, otra fuente o paginación.
7. Para comunicar fuera del área, validar con el área dueña y pasar por el Backoffice. Las skills no autorizan enviar, publicar, crear tickets ni cambiar datos.
8. Si la pregunta se repite o piden un envío periódico, propone `de-chat-a-reporte`; no crees ni actives el envío por tu cuenta.

## Decisión simple

| Situación                                      | Camino                                                            |
| ---------------------------------------------- | ----------------------------------------------------------------- |
| Se pregunta una vez                            | MCP                                                               |
| Se vuelve a preguntar esta semana              | Reporte del Backoffice o envío programado: ticket en Linear       |
| Se va a comunicar fuera del área o a Dirección | Validación del área dueña y Backoffice                            |
| Exportación o listado nominativo               | Backoffice o administrador autorizado, sólo para el caso concreto |

## Pasos

1. Para redactar el alcance no hace falta volver a consultar cifras. Si el
   usuario además pide un dato actual, atiéndelo con la skill correspondiente
   y una consulta nueva; no presentes cifras previas como vigentes.
2. Rellena `references/plantilla-linear.md` con lo que ya sabes de la
   conversación: herramienta y parámetros no sensibles, corte, perímetro y
   acceso necesario. Lo que no sepas, déjalo como pendiente. No copies fichas,
   cédulas, correos, consultas con identificadores ni credenciales al ticket.
3. Entrega el ticket listo para pegar en Linear y esta línea para el usuario:
   «Si esto se va a repetir, propone un reporte del Backoffice o un envío
   diario y deja el alcance listo para Linear».
4. Antes de pedir un reporte nuevo, pregunta si el Backoffice ya tiene una
   pantalla o un reporte que lo cubra.
5. Esto entrega un borrador. Crear un ticket en Linear, adjuntar datos, dar
   acceso o activar un envío requiere que el usuario autorice esa acción y
   destino. No declares creado, programado o enviado algo sin confirmación
   de la herramienta correspondiente.
