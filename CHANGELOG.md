# Cambios

Formato: versión del paquete, fecha, versión de la política de gobernanza del
MCP que cumple, qué cambió y qué se probó.

## 1.0.0 (2026-11-07)

Gobernanza del MCP: v0.4.

Primera versión del repositorio único de skills.

- Plugin `dacuotas` con el mismo directorio para Claude Code, Cursor y
  ChatGPT/Codex, y el servidor MCP `dwh-dacuotas`.
- Skills: `como-vamos`, `ficha-cliente`, `analisis-libre` (absorbe las recetas
  de CredoLab como referencia), `finanzas-sap` y `de-chat-a-reporte` (nuevas).
- Las cinco llevan el bloque común de reglas fijas de buen uso.
- Sin cifras, fechas de vigencia, nombres de tablas ni datos de conexión
  dentro del contenido de negocio.
- `instalar.sh` de un comando, `empaquetar.sh` para los zips de claude.ai,
  `comprobar.sh` para validar manifiestos, frontmatter y contenido sensible.
- Guías por cliente en `instalacion/`.

Probado:

- `claude plugin validate` sobre el marketplace y el plugin.
- Instalación del marketplace y del plugin en Claude Code desde el repositorio
  publicado, en un perfil temporal.
- `instalar.sh` en un perfil temporal: skills en `~/.agents/skills/`,
  servidor en `~/.cursor/mcp.json` y en Codex.
- `empaquetar.sh`: cinco zips con la carpeta de la skill en la raíz.

Sin probar en esta versión: subida de los zips a claude.ai, importación en
Cursor desde GitHub, ChatGPT web y Grok Bot.
