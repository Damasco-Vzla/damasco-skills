---
name: de-chat-a-reporte
description: Convierte una pregunta repetida del MCP de Da+Cuotas en un pedido de reporte del Backoffice o envío programado, redacta el ticket de Linear con objetivo, fuente, métrica, período, moneda, cortes, frecuencia y responsable de validar. Úsala cuando el usuario repita una consulta, diga «todos los días», «mándame», «exporta», «pásame la base» o cuando una respuesta traiga aviso de consulta recurrente.
license: Propietaria. Ver LICENSE.md del repositorio.
metadata:
  version: '1.0.0'
  repositorio: 'https://github.com/Damasco-Vzla/damasco-skills'
---

# De chat a reporte

El MCP es para explorar una vez. Lo que se repite va al Backoffice.

## Reglas fijas

1. Cada cifra sale de una llamada hecha en este turno, nunca de memoria ni de un mensaje anterior.
2. Cita `fuente` y `corte_datos` en cada cifra; no mezcles cortes de copias distintas.
3. Traslada tal cual `nota`, `aviso`, `sello`, `avisos_sql` y `aviso_volumen`.
4. Lo que no está en el catálogo (`listar_metricas`) no se responde: declara el límite, nunca un cero. Si una herramienta que pide esta guía no está en tu lista o el MCP responde «herramienta desconocida», tu rol no la tiene: no la reintentes, trabaja con las que tengas y di al usuario en una línea cuál le falta para pedirla a TI.
5. Toda cifra es de apoyo salvo que el `sello` diga `certificada`.
6. Datos de personas sólo de la persona por la que se pregunta; nunca listados.
7. Si el usuario la va a comunicar fuera de su área: «validar con el área dueña y pasar por el Backoffice».
8. Si la misma pregunta se repite o piden «todos los días», usa esta skill.

## Decisión simple

| Situación                                      | Camino                                                            |
| ---------------------------------------------- | ----------------------------------------------------------------- |
| Se pregunta una vez                            | MCP                                                               |
| Se vuelve a preguntar esta semana              | Reporte del Backoffice o envío programado: ticket en Linear       |
| Se va a comunicar fuera del área o a Dirección | Validación del área dueña y Backoffice                            |
| Exportación o listado nominativo               | Backoffice o administrador autorizado, sólo para el caso concreto |

## Pasos

1. No ejecutes la consulta otra vez.
2. Rellena `references/plantilla-linear.md` con lo que ya sabes de la
   conversación: herramienta y parámetros usados, corte, rol, perímetro. Lo
   que no sepas, déjalo como pregunta para el usuario.
3. Entrega el ticket listo para pegar en Linear y esta línea para el usuario:
   «Si esto se va a repetir, propone un reporte del Backoffice o un envío
   diario y deja el alcance listo para Linear».
4. Antes de pedir un reporte nuevo, pregunta si el Backoffice ya tiene una
   pantalla o un reporte que lo cubra.
