# Skills de Da+Cuotas para el MCP del DWH

## Qué es

Skills y configuración para usar el MCP del DWH de Da+Cuotas (crédito en Mambu,
app, compras, call center, SAP y punto de venta de tienda) desde Claude,
ChatGPT, Cursor, Codex y Grok Bot. Sólo lectura.

> Explorar con MCP. Operar con Backoffice. Validar siempre con criterio humano.

Servidor: `https://mambu-mirror.aplicacionesdamasco.com/mcp` (nombre
`dwh-dacuotas`).

## Pedir acceso

El alta la hace TI: usuario, rol por área y MFA. Sin usuario no funciona nada
de este repositorio. Aquí no se publican usuarios ni roles de personas.

## Instalar

Un comando (macOS o Linux, sin sudo). Detecta Claude Code, Codex y Cursor y
configura lo que encuentre:

```bash
curl -fsSL https://raw.githubusercontent.com/Damasco-Vzla/damasco-skills/main/instalar.sh | bash
```

Para ver qué haría sin tocar nada:

```bash
curl -fsSL https://raw.githubusercontent.com/Damasco-Vzla/damasco-skills/main/instalar.sh | bash -s -- --solo-mostrar
```

Por cliente, a mano:

| Cliente                            | Cómo                                                                                                                                                  | Guía                                 |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------ |
| Claude Code                        | `claude plugin marketplace add Damasco-Vzla/damasco-skills` y `claude plugin install dacuotas@damasco`                                                | [claude.md](instalacion/claude.md)   |
| claude.ai (web, escritorio, móvil) | Conector de la organización (pide a TI el dato para claude.ai) y zips de la [Release](https://github.com/Damasco-Vzla/damasco-skills/releases/latest) | [claude.md](instalacion/claude.md)   |
| ChatGPT web                        | Modo desarrollador, `chatgpt.com/plugins`, servidor MCP con OAuth                                                                                     | [chatgpt.md](instalacion/chatgpt.md) |
| Codex CLI                          | `codex mcp add dwh-dacuotas --url https://mambu-mirror.aplicacionesdamasco.com/mcp` y `codex mcp login dwh-dacuotas`                                  | [chatgpt.md](instalacion/chatgpt.md) |
| Cursor                             | Servidor en `~/.cursor/mcp.json` y skills en `~/.agents/skills/`                                                                                      | [cursor.md](instalacion/cursor.md)   |
| Grok                               | Grok Bot de escritorio sin soporte formal; grok.com no                                                                                                | [grok.md](instalacion/grok.md)       |

## Primer uso

1. Conecta el servidor e inicia sesión: usuario, clave y código MFA.
2. Primera pregunta sugerida: «¿Cómo vamos hoy?». Dispara la skill
   `como-vamos`, que empieza por `listar_metricas` y `analisis_vigente`.
3. Cada respuesta trae siempre:
   - `fuente`: de qué copia sale.
   - `corte_datos`: hasta cuándo llega el dato.
   - `nota`: avisos de interpretación.
   - `sello`: `calculada` (cifra de apoyo), `certificada` (sólo si el servidor
     lo dice) o `escenario` (hubo tasa o supuesto propio).

## Skills

| Skill               | Para qué                                                         |
| ------------------- | ---------------------------------------------------------------- |
| `como-vamos`        | Foto del negocio y seguimiento diario                            |
| `ficha-cliente`     | Una persona por cédula; sólo roles con datos de personas         |
| `analisis-libre`    | Cruces y cálculos con SQL cuando no hay herramienta              |
| `finanzas-sap`      | Mayor, balance, resultado por rubro, CxC, CxP, trazar documentos |
| `de-chat-a-reporte` | Convertir una pregunta repetida en un reporte del Backoffice     |

## Buenas preguntas

Toda pregunta lleva objetivo, perímetro, métrica, período en hora de Venezuela
y moneda.

1. «Ventas BNPL de ayer por canal y por hora, en USD, para ver a qué hora se
   concentra la demanda.»
2. «Colocación de esta semana por cosecha, comparada con la semana anterior.»
3. «Mora por tramo frente a las gestiones del call center de octubre, cada una
   por su lado, para ver dónde falta gestión.»
4. «Cierre del punto de venta de una tienda de ayer frente a sus facturas de
   SAP del mismo día.»
5. «Cupo aprobado de la app frente a la cartera viva de Mambu, sin sumarlos,
   para ver cuánto cupo no se usa.»
6. «Resultado del mes contable de octubre de la sociedad Productiva, por
   rubro, en moneda local y de sistema.»

## Qué no hacer

- Pedir «dame las ventas» sin definir perímetro, período ni moneda.
- Repetir la misma consulta cada mañana por chat.
- Exportar bases o pedir listados de personas.
- Sumar SAP Productiva con Importadora, o gestiones del call center con abonos.
- Publicar una cifra como oficial sin validarla con el área dueña.
- Pedir datos de personas que no son el caso concreto.

## Cuando se repite

- ¿Una vez? MCP.
- ¿Otra vez esta semana? Reporte del Backoffice o envío programado: ticket en
  Linear. La skill `de-chat-a-reporte` lo redacta.
- ¿Se comunica fuera del área? Validación del área dueña y Backoffice.

## Versiones

Cada Release lleva la versión del paquete, la versión de la política de
gobernanza del MCP que cumple, la fecha y qué se probó. Ver
[CHANGELOG.md](CHANGELOG.md). Las skills subidas a claude.ai no se actualizan
solas: con cada Release hay que volver a subir los zips.

## Soporte

[instalacion/diagnostico.md](instalacion/diagnostico.md) y, si no se resuelve,
escribir a TI.

## Licencia

Propietaria. Ver [LICENSE.md](LICENSE.md).
