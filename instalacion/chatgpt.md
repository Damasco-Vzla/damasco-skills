# ChatGPT y Codex

El servidor registra el cliente solo: no hay client id ni secreto que copiar.

## ChatGPT web (modo desarrollador)

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

## ChatGPT de escritorio y Codex, con el plugin

Añade el marketplace de este repositorio y el plugin `dacuotas` (skills y
servidor):

```bash
codex plugin marketplace add Damasco-Vzla/damasco-skills
codex plugin add dacuotas@damasco
```

Reinicia la app de escritorio de ChatGPT.

## Codex CLI, sólo el servidor

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
