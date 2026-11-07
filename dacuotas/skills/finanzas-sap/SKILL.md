---
name: finanzas-sap
description: Contabilidad de SAP de Damasco, libro mayor, balance de comprobación, resultado del mes por rubro, cuentas por cobrar y por pagar, trazar una factura o un pago. Úsala ante «mayor», «balance», «cuánto vendimos o gastamos en el mes contable», «CxC», «CxP», «traza este documento». Una sociedad por consulta.
license: Propietaria. Ver LICENSE.md del repositorio.
metadata:
  version: '1.0.1'
  repositorio: 'https://github.com/Damasco-Vzla/damasco-skills'
---

# Finanzas SAP

Cifras contables de apoyo sacadas del espejo de SAP. La cifra oficial la emite
Contabilidad.

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

- `listar_metricas` y herramientas de la sesión: comprueba acceso y esquema.
  Si el catálogo anuncia finanzas pero el cliente no expone esas herramientas,
  dilo así, sin afirmar que SAP no existe. Ofrece revisar la conexión con TI;
  no inventes llamadas ni atribuyas el problema a un rol sin evidencia.
- Sociedad obligatoria y única: Productiva o Importadora. No se suman entre
  sí. Si el usuario no la dijo, pregúntala.
- Período en fechas contables (AAAA-MM o AAAA-MM-DD). Antes de un saldo histórico,
  comprueba cobertura con `cobertura_datos` si está disponible. Si no puedes
  verificarla, no prometas reconstruir ese saldo a partir de una foto actual.

## Qué herramienta

| Pregunta                                                         | Herramienta                                                                                       |
| ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| Resultado del mes, cuánto vendimos o gastamos en el mes contable | `resultado_por_rubro` (`sociedad`, `anio_mes`)                                                    |
| Saldos por cuenta en un período                                  | `balance_comprobacion`                                                                            |
| Líneas de una cuenta                                             | `mayor` (paginado; para analizar una cuenta, no para exportar el mayor)                           |
| Cuentas por cobrar o por pagar a una fecha                       | `cxc`, `cxp`                                                                                      |
| Trazar facturas, notas de crédito, compras, cobros o pagos       | `trazar_documento` con varios `docentries` del mismo tipo juntos, nunca una llamada por documento |
| Qué historia contable hay cargada                                | `cobertura_datos`                                                                                 |

Los nombres anteriores son rutas posibles, no una garantía de disponibilidad.
Usa el esquema real para los parámetros. Sólo si ninguna responde, pasa a
`analisis-libre`, con objetos autorizados y diccionario disponible; una
denegación de acceso no se resuelve con SQL alternativo.

## Reglas contables

- Moneda nativa: identifica la moneda de cada importe en la respuesta o el
  diccionario. No supongas que la moneda de sistema es USD ni que la moneda del
  documento es la del asiento. No apliques tasas; una conversión solicitada
  es un `escenario` con tasa, fuente, fecha y sentido explícitos.
- Fecha contable, no fecha de creación del documento.
- Las líneas con importe en una sola moneda hacen que el total en moneda local
  no se compare con el de sistema: si el servidor lo avisa, trasládalo.
- Explica el signo contable antes de llamar ganancia o pérdida a un neto de
  débito menos crédito. Usa el criterio devuelto, no inviertas signos en silencio.
- Un agregado de compras de la app o colocación no sustituye ventas contables
  de SAP. Una foto actual de CxC/CxP no es un saldo histórico reconciliado.
- Traslada las exclusiones de la herramienta: por ejemplo, si CxP no incluye
  notas de crédito de proveedor, no lo presentes como pasivo neto completo.
- `sello`: `calculada` es cifra de apoyo; `certificada` sólo si el servidor lo
  dice. Nunca presentes una cifra como oficial.

## Cómo entregas la respuesta

Cifra, sociedad, moneda, período, corte de SAP y sello. Si el balance no
cuadra, el servidor lo avisa: dilo antes de la cifra. Si la cifra va a
Dirección o fuera de la empresa: «validar con Contabilidad y pasar por el
Backoffice».
