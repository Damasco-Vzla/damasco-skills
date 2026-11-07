# Cursor

## Servidor MCP

Global, para todos los proyectos: `~/.cursor/mcp.json`.

```json
{
  "mcpServers": {
    "dwh-dacuotas": {
      "url": "https://mambu-mirror.aplicacionesdamasco.com/mcp"
    }
  }
}
```

Si el fichero ya existe, añade la entrada dentro de `mcpServers` sin borrar las
demás. `instalar.sh` hace esa mezcla y deja una copia `.bak`.

Después: Cursor, Settings, MCP. El servidor sale pendiente de autenticar; al
pulsar se abre el inicio de sesión. Al volver debe salir en verde con la lista
de herramientas.

## Skills

Cursor lee las skills de `~/.agents/skills/` (las mismas que usa Codex).
`instalar.sh` copia ahí las cinco skills de `dacuotas/skills/`.

## Alternativas

- Importar el repositorio como plugin: Customize, From GitHub Repository, URL
  de este repositorio. Usa `.cursor-plugin/marketplace.json`.
- Copiar la carpeta `dacuotas/` a `~/.cursor/plugins/local/dacuotas`.

En Cursor Enterprise lo puede controlar el administrador.

## Lo que hoy funciona

- Cursor de escritorio: sí, con callback local.
- Cursor web y Cursor Agents: todavía no; su dominio no está admitido para
  registrar clientes.
