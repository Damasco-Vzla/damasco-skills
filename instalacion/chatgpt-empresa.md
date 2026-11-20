# ChatGPT de empresa: el admin lo instala para todos

Para gente no técnica. El admin del espacio de ChatGPT sube el plugin una vez y
lo deja instalado para todos. Cada persona sólo inicia sesión la primera vez.
Nadie necesita el modo desarrollador ni la terminal.

Los GPT personalizados se retiran el 11-dic-2026 (11-feb-2027 en Enterprise con
prórroga); los sustituyen los plugins. Este es el reemplazo del GPT «Da+Cuotas».

## Admin u owner del espacio (una vez)

1. Descargar `dacuotas-chatgpt.zip` de la última Release de este repositorio
   (o generarlo con `./empaquetar.sh`, queda en `dist/`).
2. En [Admin console](https://admin.openai.com), elegir el espacio y abrir
   **Plugins**.
3. **Add**, **Upload plugin**, subir el zip.
4. En el plugin, elegir **Installed for workspace**: queda instalado para todos.
   Para limitarlo a unos roles, **Customize by role**.
5. Probarlo con tu usuario (abajo) antes de avisar a nadie.

Nueva versión: en el detalle del plugin, **Upload new version** con el zip nuevo.

Si no aparece la opción de subir, revisar en los permisos del espacio
**Upload plugins** y **Upload plugins with custom MCP servers**.

## Cada persona (la primera vez)

Requisito: tener usuario del MCP de Da+Cuotas (lo da Tecnología) con su código
de verificación en el móvil.

1. Abrir un chat nuevo y preguntar, por ejemplo, «¿Cómo vamos hoy?».
2. ChatGPT pide conectar Da+Cuotas: pulsar **Conectar**.
3. Entrar con el usuario, la clave y el código de verificación.

Listo. Desde ahí sólo se pregunta. Si un día vuelve a pedir el inicio de sesión,
es normal: se repite el paso 3.

Si no responde con datos: escribir «usa Da+Cuotas» en el chat, o en el menú «+»
del chat marcar Da+Cuotas.
