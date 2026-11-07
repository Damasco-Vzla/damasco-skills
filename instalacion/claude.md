# Claude

## Claude Code

Con el plugin (trae las skills y el servidor MCP):

```bash
claude plugin marketplace add Damasco-Vzla/damasco-skills
claude plugin install dacuotas@damasco
```

Después, dentro de una sesión de Claude Code: `/mcp`, elegir `dwh-dacuotas` e
iniciar sesión (usuario, clave y código MFA). Se abre el navegador.

Actualizar a una versión nueva:

```bash
claude plugin marketplace update damasco
claude plugin update dacuotas@damasco
```

Sólo el servidor, sin skills:

```bash
claude mcp add --transport http dwh-dacuotas https://mambu-mirror.aplicacionesdamasco.com/mcp -s user
```

No uses las dos formas a la vez: tendrías el mismo servidor dos veces. Si ya
lo diste de alta a mano y pasas al plugin, quítalo antes con
`claude mcp remove dwh-dacuotas -s user`.

## claude.ai (web, escritorio y móvil)

Hace falta un plan con conectores personalizados.

### Conector

Lo añade el propietario de la organización de Claude, una vez para todos:

1. Ajustes de la organización, Conectores, Añadir conector personalizado.
2. Nombre `Da+Cuotas`, URL `https://mambu-mirror.aplicacionesdamasco.com/mcp`.
3. Opciones avanzadas: «Usa tu propio cliente OAuth». Pide a TI el dato para
   claude.ai. El secreto va en blanco.

Cada persona, después: Ajustes, Conectores, `Da+Cuotas`, Conectar, e iniciar
sesión con su usuario.

### Skills

1. Descarga los zips de la última
   [Release](https://github.com/Damasco-Vzla/damasco-skills/releases/latest):
   uno por skill.
2. Ajustes, Capacidades, Skills, Subir skill. Un zip cada vez.
3. En organizaciones Team o Enterprise, un administrador puede subirlas una
   vez para todos.

Las skills subidas no se actualizan solas: con cada Release nueva hay que
volver a subir los zips.
