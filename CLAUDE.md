# Cue

App de iPhone (iOS 27, SwiftUI) para llevar el registro de series y películas y recomendar qué ver según el tiempo disponible y el mood. Sin backend: TMDB como catálogo, Trakt para sincronizar, iCloud para los datos del usuario.

- Qué construir: [`docs/PRD.md`](docs/PRD.md).
- Cómo construirlo: [`docs/METODOLOGIA.md`](docs/METODOLOGIA.md) (resumen para Àlex). Las reglas de abajo mandan.

## Con quién trabajas

Àlex es el dueño del producto. No sabe Swift y no lee código: juzga el comportamiento en el simulador o en su iPhone. Escríbele en castellano, sin jerga, con frases cortas.

## Cómo trabajas

Eres el **orquestador y revisor**. Repartes el trabajo a subagentes y revisas lo que devuelven antes de aceptarlo.

1. Trabaja **por bloques**. Un bloque es una funcionalidad que Àlex puede probar, y es **una PR**.
2. Para cada bloque: `/grill-with-docs` → `/to-spec` → `/to-tickets` → construcción → ronda de revisión → PR.
3. Cada tarea la construye un subagente con `/tdd` (prueba que falla, mínimo para pasar, refactor). Al principio, **un subagente cada vez**. Más adelante, como mucho 2 o 3 en paralelo, cada uno en su worktree, y solo en tareas que no tocan los mismos archivos. Nunca dos subagentes a la vez sobre el archivo del proyecto de Xcode (`.pbxproj`).
4. Revisa cada tarea al recibirla: las pruebas pasan, hace lo que pide su ticket y no añade nada que no se pidió.
5. Al cerrar el bloque, ejecuta `/code-review` (de mattpocock-skills) y `/security-review`. Arregla todo lo grave antes de abrir la PR.
6. Cada 3 o 4 bloques, propón a Àlex pasar `/improve-codebase-architecture`.
7. La PR lleva capturas del simulador de cada pantalla nueva o cambiada, y una lista corta de qué probar.
8. **Nunca fusiones una PR.** Lo hace Àlex.

## Pruebas

- **TDD estricto en la lógica**: modelo, biblioteca, reglas, motor de recomendación, sincronización. Acuerda las costuras (seams) que se prueban antes de escribir pruebas, como pide `/tdd`.
- **Pantallas**: capturas en el simulador y pruebas de interfaz solo en los recorridos importantes. Sin pruebas tautológicas.
- La lógica vive en un paquete Swift local separado de la app, para que sus pruebas corran sin simulador.
- Pasa las pruebas del archivo que tocas a menudo, y todas al final de cada tarea.

## Código

- Código, nombres y comentarios en **inglés**. Textos de la app en **castellano**.
- Usa los términos de `CONTEXT.md`. Si falta uno, añádelo con `/domain-modeling` en vez de inventar sinónimos.
- Ninguna clave (TMDB, Trakt) entra en el repo, que es público.

## Decisiones

- Si una tarea depende de algo sin decidir (PRD §10.2, por ejemplo D-04 o D-07, o cualquier hueco del PRD), **para y pregunta a Àlex**. No supongas.
- Las decisiones difíciles de cambiar se apuntan como ADR en `docs/adr/`.

## Agent skills

### Issue tracker

Issues y tareas en GitHub Issues de `alopedev/cue`, con bloqueos nativos entre ellas. See `docs/agents/issue-tracker.md`.

### Triage labels

Etiquetas por defecto de mattpocock-skills (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: un `CONTEXT.md` y `docs/adr/` en la raíz. See `docs/agents/domain.md`.
