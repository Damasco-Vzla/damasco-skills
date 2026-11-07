# Plantilla de ticket para Linear

Copia el bloque y rellena cada campo. Lo que no se sepa queda pendiente.
Es un borrador sin datos personales ni secretos; no crea ni programa nada.

```markdown
## Título

Reporte <frecuencia> de <métrica> por <perímetro>

## Objetivo

Qué decisión se toma con este reporte y quién la toma.

## Fuente(s) y herramienta del MCP

Herramienta disponible y parámetros no sensibles con que se calculó en el chat (por ejemplo
`analisis_vigente` con `cartera_diaria`, o `compras_app` con `agrupar_por`).

## Métrica y definición

Qué se cuenta o se suma, clave/granularidad, numerador y denominador de ratios,
tratamiento de duplicados y qué queda fuera.

## Período y frecuencia

Período en hora de Venezuela. Frecuencia: diaria, semanal, mensual. Hora de
envío si es programado.

## Moneda

Código de moneda de cada importe, sin asumir que sistema significa USD. Si
hace falta tasa, valor, fuente, fecha y sentido de conversión; es un escenario.

## Cortes aceptables

Antigüedad máxima por fuente y qué hacer si falta carga o cobertura, una
fuente está retrasada o la respuesta está recortada. No enviar ceros ficticios.

## Perímetro

Tienda, canal, sociedad, producto. Una sociedad de SAP por reporte.

## Responsable de validar

Área dueña del dato que valida la cifra antes de que circule.

## Destinatarios

Quién lo recibe, por qué canal, nivel de acceso y autorización de envío.

## Criterio de aceptación

Cómo se sabe que el reporte está bien: fórmula, cifra de control y fuente,
cuadre con Backoffice, fecha de prueba y respuesta ante fallo. Las cifras de
control de una conversación anterior se etiquetan históricas, no vigentes.
```
