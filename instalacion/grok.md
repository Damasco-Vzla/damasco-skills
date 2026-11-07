# Grok

## Grok Bot de escritorio (sin soporte formal)

Está construido sobre Cursor, así que se configura igual:

- Servidor en el `mcp.json` de Grok Bot, con la misma entrada que en
  [cursor.md](cursor.md).
- Skills en `~/.agents/skills/` (`instalar.sh` las deja ahí).

El inicio de sesión registra el cliente solo y vuelve por un callback local.
Funciona, pero no se prueba en cada versión.

## grok.com (web): descartado

grok.com no registra el cliente de forma dinámica: usa un client id fijo con
su propio callback. Para admitirlo haría falta crear un cliente manual por
proveedor y admitir su dominio en el servidor de autorización, lo que amplía
la superficie de acceso. Sin demanda declarada, no se habilita. Si un área lo
necesita, que lo pida a TI con el caso de uso.
