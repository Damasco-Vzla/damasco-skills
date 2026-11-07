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
configura lo que encuentre. Requiere Bash y, para fusionar la configuración
de Cursor, Python 3. Conserva las skills previas en
`~/.agents/skills/.damasco-backups` y las configuraciones de Cursor en copias
`.bak.*` únicas. Revisa el script antes de ejecutarlo:

Si ya hay un servidor con el mismo nombre pero otra URL o un transporte
incompatible, lo conserva y avisa para revisión manual. No traslada credenciales
de una conexión a otra.

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
   `como-vamos`, que empieza por `listar_metricas` y comprueba las herramientas
   expuestas en esa sesión. Usa `analisis_vigente` si está disponible o
   `resumen` para crédito, aclarando el alcance.
3. Cada respuesta debe conservar los metadatos que devuelva el servidor:
   - `fuente`: de qué copia sale.
   - Corte por fuente/objeto: `corte_datos`, `corte_fuente` o `cortes`, según la
     respuesta. El corte principal no representa necesariamente SAP. La fecha
     de copia no demuestra cobertura del período pedido.
   - `nota`: avisos de interpretación.
   - `sello`: `calculada` (cifra de apoyo), `certificada` (sólo si el servidor
     lo dice) o `escenario` (hubo tasa o supuesto propio).
   - Período, moneda/unidad y filtros. Si un metadato no viene, no se inventa.

El catálogo puede anunciar herramientas que un cliente todavía no expone o
venir recortado. Esto no prueba que el dato no exista ni que esté denegado.
Ver [diagnóstico](instalacion/diagnostico.md). El catálogo de métricas tampoco
sustituye el diccionario de objetos para análisis ad hoc autorizado.

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
- Interpretar una fecha de copia reciente como prueba de datos actuales: en
  Cashea u otras fuentes externas, comprobar histórico, archivo vigente y
  cobertura antes de responder.
- Dar por ejecutada una SQL redactada, por total unas filas recortadas o por
  USD una moneda no verificada.

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

## Desarrollar y comprobar

Python 3.10 o posterior para las herramientas de mantenimiento. Las pruebas
usan hogares temporales y clientes simulados; no inician sesión ni consultan
datos reales:

```bash
python3 -m pip install -r requirements-dev.txt
bash comprobar.sh
python3 -m unittest discover -s tests -v
bash -n instalar.sh comprobar.sh empaquetar.sh
bash empaquetar.sh
```

`comprobar.sh` valida YAML/JSON, coherencia de versiones, rutas, conexión MCP
y patrones de contenido sensible. Es una barrera adicional, no garantía de
ausencia de datos sensibles. `empaquetar.sh` produce cinco zips reproducibles
y `dist/SHA256SUMS`. Publicar una Release exige un tag `vX.Y.Z` que coincida
con los manifiestos. No confundir estas pruebas con validación de consultas
de negocio ni con autenticación real en todos los clientes.

Antes de publicar, completa los [casos de comportamiento](pruebas/casos-skills.md)
y las pruebas de clientes que correspondan. Instrucciones para colaboradores
en [AGENTS.md](AGENTS.md).

## Soporte

[instalacion/diagnostico.md](instalacion/diagnostico.md) y, si no se resuelve,
escribir a TI.

## Licencia

Propietaria. Ver [LICENSE.md](LICENSE.md).
