# Diagnóstico

## No me deja entrar

| Síntoma                                                        | Qué pasa                                                                                         | Qué hacer                                                           |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------- |
| El cliente no abre el navegador                                | No llegó a llamar al servidor                                                                    | Revisa que la URL termine en `/mcp` y reinicia el cliente           |
| El navegador abre el inicio de sesión y al volver no pasa nada | El inicio de sesión murió en el cliente: pestaña vieja, navegador incrustado o cuenta equivocada | Cierra todas las pestañas de inicio de sesión y repite una sola vez |
| `ERR_CONNECTION_REFUSED` en `127.0.0.1`                        | Se completó el inicio de sesión en una pestaña de un intento anterior                            | Igual que arriba: un solo intento, en la pestaña nueva              |
| Inicia sesión pero luego da 401                                | La cuenta existe pero no tiene acceso al MCP                                                     | Escribe a TI                                                        |
| Pide el código MFA y no lo tienes                              | MFA obligatorio fuera de la red                                                                  | Escribe a TI para configurarlo                                      |

Que el servidor responda 401 sin sesión es normal: es lo que dispara el inicio
de sesión del cliente.

## Entra pero no responde lo que pido

- «No está en el catálogo»: comprueba si vino completo o recortado. Una métrica
  ausente no prueba falta de acceso, y el catálogo de métricas no enumera todos
  los objetos que puede describir `describir_datos`.
- El catálogo anuncia una herramienta pero el cliente no la muestra: comprueba
  conexión, actualización y esquema expuesto. No inventes una llamada ni
  concluyas que falta permiso sin evidencia. Usa sólo una alternativa disponible
  y autorizada que cubra el mismo alcance, indicando las diferencias.
- 403 o denegación explícita: detente. Los permisos los cambia TI con
  autorización del área; no los rodees con SQL ni otra conexión.
- 504: la consulta es demasiado grande. Acota el período o agrupa más.
- Responde con 0 filas: lee la `nota` de la respuesta antes de concluir que no
  hay datos.
- Cifra rara: revisa el corte de esa fuente/objeto, no sólo `corte_datos`, y la
  cobertura de negocio. Una copia de hoy puede contener sólo historia antigua.

## Las skills no aparecen

- Claude Code: `claude plugin list` debe mostrar `dacuotas@damasco`. Si no,
  repite la instalación.
- Cursor y Codex: `ls ~/.agents/skills/` debe mostrar las cinco carpetas.
- claude.ai: Ajustes, Capacidades, Skills. Si subiste una versión vieja,
  bórrala y sube la nueva.

## Comprobación del servidor

```bash
curl -s https://mambu-mirror.aplicacionesdamasco.com/.well-known/oauth-authorization-server
```

Debe devolver un JSON con `registration_endpoint`. Si no responde, avisa a TI.
