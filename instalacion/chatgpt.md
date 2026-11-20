# ChatGPT y Codex

## ChatGPT de Damasco (lo normal)

Si usas el ChatGPT de la empresa, Da+Cuotas ya viene instalado. No hay que
activar nada ni copiar direcciones.

Antes necesitas tu usuario de Da+Cuotas (correo con usuario y clave). Si no lo
tienes, pídelo a Tecnología.

1. Abre un chat nuevo en ChatGPT.
2. Escribe `@Cuotas`, elige **Da+Cuotas** y pregunta, por ejemplo:
   «¿cómo vamos hoy?».
3. La primera vez sale el botón **Conectar**. Púlsalo, entra con tu usuario y
   tu clave y escribe el código de verificación del móvil.
4. Listo. Las siguientes veces basta con preguntar.

Si no responde con datos: escribe «usa Da+Cuotas» al principio de la pregunta.
Si sigue sin funcionar, cierra ChatGPT, vuelve a abrirlo y avisa a Tecnología.

Ideas de preguntas: «¿cómo vamos hoy?», «mora de la cartera este mes»,
«ficha del cliente con cédula 12345678», «resultado de octubre por rubro».

### Para el administrador del espacio de ChatGPT

Se hace una sola vez y se actualiza solo desde este repositorio.

1. Admin console, Complementos, Añadir, **Importar marketplace**.
2. Origen: `https://github.com/Damasco-Vzla/damasco-skills` (sólo el repo, sin
   rama ni carpeta). Lee `.agents/plugins/marketplace.json`.
3. En el complemento Da+Cuotas:
   - Disponibilidad: **Instalado** (o personalizar por rol).
   - Sitios: **apagado**. Son datos internos.
4. Lo que entra en `main` se sincroniza solo cada día. Para que llegue ya:
   Marketplaces, el repo, **Sincronizar ahora**.

No subas además un ZIP del mismo plugin: el import falla con «Existing catalog
plugin belongs to a different imported source». Hay que borrar el ZIP y
sincronizar.

Subir o sincronizar el plugin no conecta a nadie: cada persona inicia sesión
con su usuario la primera vez. El usuario tiene que estar en el grupo
`DaCuotas-Espejo` de Cognito.

## Otras formas (técnicas)

El servidor registra el cliente solo: no hay client id ni secreto que copiar.

### ChatGPT web (modo desarrollador)

Cuentas Plus, Pro, Business, Enterprise o Edu. En Business sólo un
administrador puede activar el modo desarrollador.

1. Ajustes, Seguridad e inicio de sesión, activar Modo desarrollador.
2. Ir a `chatgpt.com/plugins` y pulsar «+».
3. «Add custom MCP server»: nombre `Da+Cuotas`, URL
   `https://mambu-mirror.aplicacionesdamasco.com/mcp`, autenticación OAuth
   sin client id.
4. Iniciar sesión con tu usuario, aceptar el aviso y crear el plugin.
5. En un chat, menú «+», Modo desarrollador, marcar `Da+Cuotas`.

Cuando cambie el servidor: abrir la conexión en `chatgpt.com/plugins`, pulsar
«Refresh» y empezar una conversación nueva.

Las reglas de buen uso las manda el propio servidor al conectar; no hay que
pegar nada. Las skills de este repositorio en ChatGPT web sólo llegan con el
plugin de escritorio (abajo).

### ChatGPT de escritorio y Codex, con el plugin

Añade el marketplace de este repositorio y el plugin `dacuotas` (skills y
servidor):

```bash
codex plugin marketplace add Damasco-Vzla/damasco-skills
codex plugin add dacuotas@damasco
```

Reinicia la app de escritorio de ChatGPT.

### Codex CLI, sólo el servidor

```bash
codex mcp add dwh-dacuotas --url https://mambu-mirror.aplicacionesdamasco.com/mcp
codex mcp login dwh-dacuotas
```

Equivalente en `~/.codex/config.toml`:

```toml
[mcp_servers.dwh-dacuotas]
url = "https://mambu-mirror.aplicacionesdamasco.com/mcp"
```

Las skills sueltas para Codex van en `~/.agents/skills/`; `instalar.sh` las
copia ahí. No combines las skills sueltas con el plugin: saldrían repetidas.
