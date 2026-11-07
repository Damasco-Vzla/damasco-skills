---
name: finanzas-sap
description: Contabilidad de SAP de Damasco, libro mayor, balance de comprobación, resultado del mes por rubro, cuentas por cobrar y por pagar, trazar una factura o un pago. Úsala ante «mayor», «balance», «cuánto vendimos o gastamos en el mes contable», «CxC», «CxP», «traza este documento». Una sociedad por consulta.
license: Propietaria. Ver LICENSE.md del repositorio.
metadata:
  version: '1.0.0'
  repositorio: 'https://github.com/Damasco-Vzla/damasco-skills'
---

# Finanzas SAP

Cifras contables de apoyo sacadas del espejo de SAP. La cifra oficial la emite
Contabilidad.

## Reglas fijas

1. Cada cifra sale de una llamada hecha en este turno, nunca de memoria ni de un mensaje anterior.
2. Cita `fuente` y `corte_datos` en cada cifra; no mezcles cortes de copias distintas.
3. Traslada tal cual `nota`, `aviso`, `sello`, `avisos_sql` y `aviso_volumen`.
4. Lo que no está en el catálogo (`listar_metricas`) no se responde: declara el límite, nunca un cero.
5. Toda cifra es de apoyo salvo que el `sello` diga `certificada`.
6. Datos de personas sólo de la persona por la que se pregunta; nunca listados.
7. Si el usuario la va a comunicar fuera de su área: «validar con el área dueña y pasar por el Backoffice».
8. Si la misma pregunta se repite o piden «todos los días», usa la skill `de-chat-a-reporte`.

## Antes de llamar

- `listar_metricas`: comprueba que tu rol tiene las herramientas de finanzas.
- Sociedad obligatoria y única: Productiva o Importadora. No se suman entre
  sí. Si el usuario no la dijo, pregúntala.
- Período en fechas contables (AAAA-MM o AAAA-MM-DD). Si puede no estar
  cargado, `cobertura_datos` primero.

## Qué herramienta

| Pregunta                                                         | Herramienta                                                                                       |
| ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| Resultado del mes, cuánto vendimos o gastamos en el mes contable | `resultado_por_rubro` (`sociedad`, `anio_mes`)                                                    |
| Saldos por cuenta en un período                                  | `balance_comprobacion`                                                                            |
| Líneas de una cuenta                                             | `mayor` (paginado; para analizar una cuenta, no para exportar el mayor)                           |
| Cuentas por cobrar o por pagar a una fecha                       | `cxc`, `cxp`                                                                                      |
| Trazar facturas, notas de crédito, compras, cobros o pagos       | `trazar_documento` con varios `docentries` del mismo tipo juntos, nunca una llamada por documento |
| Qué historia contable hay cargada                                | `cobertura_datos`                                                                                 |

Usa estas herramientas antes que SQL libre. Sólo si ninguna responde, pasa a
`analisis-libre`.

## Reglas contables

- Moneda nativa: moneda local y moneda de sistema vienen en la respuesta. No
  apliques tasas; si el usuario pide una conversión con tasa propia, el
  resultado es un `escenario` y lo dices.
- Fecha contable, no fecha de creación del documento.
- Las líneas con importe en una sola moneda hacen que el total en moneda local
  no se compare con el de sistema: si el servidor lo avisa, trasládalo.
- `sello`: `calculada` es cifra de apoyo; `certificada` sólo si el servidor lo
  dice. Nunca presentes una cifra como oficial.

## Cómo entregas la respuesta

Cifra, sociedad, moneda, período, corte de SAP y sello. Si el balance no
cuadra, el servidor lo avisa: dilo antes de la cifra. Si la cifra va a
Dirección o fuera de la empresa: «validar con Contabilidad y pasar por el
Backoffice».
