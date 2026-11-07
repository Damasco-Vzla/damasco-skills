# Trabajar en este repositorio

Este repositorio es público. Contiene instrucciones de uso, no datos del DWH.
Lee la skill y sus referencias antes de cambiar su comportamiento. Mantén el
español, el alcance de sólo lectura y cada zip de skill autosuficiente.

## Cambios

- Trabaja en una rama; propón una pull request en borrador. No publiques una
  Release, fusiones ni despliegues como efecto de una revisión.
- Verifica catálogo, herramientas expuestas y esquemas por separado. No fijes
  en las skills nombres de tablas, coberturas, cifras o capacidades deducidas
  de una sesión. Conserva las diferencias de acceso entre clientes.
- No incluyas fichas, identificadores personales, correos, respuestas reales,
  secretos ni consultas con literales sensibles en código, fixtures o logs.
  Los casos de prueba deben ser sintéticos. No consultes personas para probar.
- Toda cifra requiere resultado recibido, fuente, corte por objeto, unidad y
  alcance. No certifiques una política o una cifra por inferencia.
- Versiona juntos los manifiestos, marketplaces y metadata de las cinco skills.
  El bloque de reglas fijas se conserva en cada skill porque se empaquetan
  por separado. Si cambia una regla compartida, revisa las cinco.

## Verificar antes de entregar

```bash
python3 -m pip install -r requirements-dev.txt
bash comprobar.sh
python3 -m unittest discover -s tests -v
bash -n instalar.sh comprobar.sh empaquetar.sh
bash empaquetar.sh
git diff --check
```

Para cambios de comportamiento, recorre `pruebas/casos-skills.md`. Las pruebas
de scripts no prueban SQL, autorización real ni decisiones del modelo. Indica
qué pasó, qué falló y qué no se ejecutó. Si el cliente Claude está instalado,
valida el marketplace y el plugin con `claude plugin validate .` y
`claude plugin validate ./dacuotas`. No instales ni autentiques clientes en el
perfil real del usuario sólo para validar este repositorio.
