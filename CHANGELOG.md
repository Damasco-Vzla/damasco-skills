# Cambios

Formato: versión del paquete, fecha, versión de la política de gobernanza del
MCP que cumple, qué cambió y qué se probó.

## 1.0.1 (sin publicar)

Referencia de gobernanza: se conserva la v0.4 declarada por la 1.0.0; esta
revisión no acredita por sí sola conformidad con una política externa.

- Las cinco skills distinguen catálogo, herramientas expuestas, acceso y
  cobertura. Resumen alternativo si falta el análisis precalculado, sin
  inventar capacidades ni convertir ausencias en cero.
- Corte por fuente/objeto, fechas relativas en Caracas, moneda verificada,
  cobertura histórica y límites de Cashea/Excel externo.
- Ficha de cliente sin consulta global de duplicados ni cruces de identidad
  sólo por dígitos. SQL con control de granularidad, particiones según objeto,
  recortes, ratios y denegaciones; trazabilidad sin exponer PII.
- CredoLab: JSON inválido o ausente no equivale a score cero; las alertas no
  prueban fraude. Reportes recurrentes como borradores, sin envíos implícitos.
- Instalación con respaldo de skills, fusión y escritura atómica de Cursor,
  prevalidación de fuentes y modo simulación sin descargas. Conflictos de URL
  o transporte se conservan sin trasladar headers ni autenticación.
- Validación real de YAML/JSON, claves duplicadas, coherencia entre clientes,
  nombres con espacios y errores de Git. PyYAML sólo para desarrollo.
- Zips reproducibles y SHA256SUMS. CI ejecuta regresiones y verifica versión
  del tag antes de publicar. AGENTS y casos sintéticos para revisar conducta.

Probado localmente el 2026-11-07:

- 26 pruebas automáticas de regresión sin red, con HOME temporal y clientes
  simulados; validación de contenido, `bash -n`, `git diff --check` y cinco zips.
- Comparación de hashes de dos empaquetados con fechas de archivo distintas.
- Contraste de catálogo y esquemas disponibles del MCP, sólo lectura y sin
  consultar fichas de personas. Esto no es prueba de SQL ni de todos los roles.

Sin probar en esta revisión: autenticación real, instalación interactiva en
cada cliente, subida a claude.ai, ejecución SQL de las recetas o validación
legal/funcional de la política de gobernanza. Los casos de comportamiento no
son pruebas automáticas. No se publica una Release como parte de la revisión.

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
