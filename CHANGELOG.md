# Cambios

Formato: versión del paquete, fecha, versión de la política de gobernanza del
MCP que cumple, qué cambió y qué se probó.

## 1.0.1 (2026-11-09)

Gobernanza del MCP: v0.4. Servidor MCP v1.0.19.

- Regla 4 de las cinco skills: si una herramienta no está en la lista del rol
  (o el MCP responde «herramienta desconocida»), no reintentar, trabajar con
  las que haya y decir al usuario cuál le falta para pedirla a TI.
- El servidor permite `listar_metricas` a todo rol y, al conectar, avisa del
  repositorio de skills con la forma de cargarlas según el cliente.

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

- `claude plugin validate` del marketplace y del plugin, sin errores.
- `instalar.sh` por `curl | bash` desde el repositorio publicado, en un perfil
  temporal: marketplace y plugin en Claude Code (5 skills y el servidor),
  skills en `~/.agents/skills/`, servidor fusionado en `~/.cursor/mcp.json`
  sin borrar otros, y servidor en Codex.
- `claude plugin marketplace add Damasco-Vzla/damasco-skills` sin llave SSH:
  reintenta por HTTPS y funciona.
- `codex plugin marketplace add Damasco-Vzla/damasco-skills` y
  `codex plugin add dacuotas@damasco`.
- `empaquetar.sh`: cinco zips con la carpeta de la skill en la raíz.

Sin probar en esta versión: subida de los zips a claude.ai, importación en
Cursor desde GitHub, ChatGPT web y Grok Bot.
