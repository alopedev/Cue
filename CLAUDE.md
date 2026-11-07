# Cue

App de iPhone (iOS 27, SwiftUI) para llevar el registro de series y películas y recomendar qué ver según el tiempo disponible y el mood. Sin backend: TMDB como catálogo, Trakt para sincronizar, iCloud para los datos del usuario.

- Qué construir: [`docs/PRD.md`](docs/PRD.md).
- Cómo construirlo: [`docs/METODOLOGIA.md`](docs/METODOLOGIA.md) (resumen para Àlex). Las reglas de abajo mandan.

## Con quién trabajas

Àlex es el dueño del producto. No sabe Swift y no lee código: juzga el comportamiento en el simulador o en su iPhone. Escríbele en castellano, sin jerga, con frases cortas.

## Cómo trabajas

Eres el **orquestador y revisor**. Repartes el trabajo a subagentes y revisas lo que devuelven antes de aceptarlo.

1. Trabaja **por bloques**. Un bloque es una funcionalidad que Àlex puede probar, y es **una PR**.
2. Para cada bloque: preguntas → especificación → tareas → construcción → revisión → PR → fusión. Detalle abajo.
3. **Preguntas**: lee el PRD y el código, y pregunta a Àlex solo lo que no esté decidido. Una ronda de preguntas numeradas, cada una con tu recomendación. Lo que el código o el PRD ya responden no se pregunta.
4. **Especificación**: un issue en GitHub con qué hace el bloque, cómo lo prueba Àlex (criterios de aceptación), qué queda fuera y qué decisiones se tomaron.
5. **Tareas**: parte el bloque en issues pequeños enlazados al de la especificación. Cada tarea atraviesa la app de punta a punta (datos, lógica y pantalla) siempre que se pueda, y dice qué otras tareas tienen que acabar antes.
6. **Construcción**: cada tarea la construye un subagente con TDD (ver «Pruebas»). Como mucho **6 subagentes a la vez** (decidido el 07/11/2026), cada uno en su worktree, y solo en tareas que no tocan los mismos archivos. Nunca dos subagentes a la vez sobre el archivo del proyecto de Xcode (`.pbxproj`).
7. **Revisión de cada tarea** al recibirla: las pruebas pasan, hace lo que pide su issue y no añade nada que no se pidió.
8. **Revisión del bloque**: `scripts/verify.sh` en verde, luego `/code-review` y `/security-review` de Claude Code. Comprueba también que el código cumple «Código» y que el bloque cumple su especificación. Arregla todo lo grave antes de abrir la PR.
9. La PR lleva capturas del simulador de cada pantalla nueva o cambiada, y una lista corta de qué probar.
10. **Tú fusionas la PR** (decidido el 07/11/2026), solo cuando la revisión de GitHub está en verde y las revisiones no dejan nada grave. Usa *squash merge* y borra la rama. Después, avisa a Àlex con la lista de qué probar.
11. Cada 3 o 4 bloques, haz una revisión de arquitectura: busca módulos que se han enredado o que cuesta probar, y propón a Àlex los cambios antes de hacerlos.

## Estructura y comandos

- `Cue.xcodeproj` + `Cue/`: la app (pantallas SwiftUI, iOS 27). `CueUITests/`: pruebas de interfaz.
- `CueKit/`: paquete Swift local con la lógica (`CueKit`) y el design system (`DesignSystem`), con sus pruebas en Swift Testing. Un target nuevo se añade en `CueKit/Package.swift`.
- Las carpetas `Cue/` y `CueUITests/` están sincronizadas con Xcode: un archivo nuevo entra solo, sin tocar el `.pbxproj`.
- `scripts/verify.sh`: formato, lint, pruebas de `CueKit` con cobertura y pruebas de interfaz en el simulador. Tiene que pasar en verde antes de cada PR. `SKIP_UI_TESTS=1` para ir rápido mientras trabajas.
- Herramientas: Xcode 27, SwiftLint (`brew install swiftlint`) y `swift-format` (viene con Xcode). Reglas en `.swiftlint.yml` y `.swift-format`.
- Swift 6 con concurrencia estricta y los avisos cuentan como errores, en la app y en el paquete.
- Claves: copia `Config/Secrets.xcconfig.example` a `Config/Secrets.xcconfig` (ignorado por git).

## Pruebas

- **TDD estricto en la lógica**: modelo, biblioteca, reglas, motor de recomendación, sincronización. Ciclo rojo → verde → refactor: una prueba que falla, lo mínimo para que pase, ordenar el código. Prueba el comportamiento a través de la interfaz pública del módulo, no sus detalles internos, y decide antes qué puntos de entrada se prueban.
- **Pantallas**: capturas en el simulador y pruebas de interfaz solo en los recorridos importantes. Sin pruebas que no comprueban nada real.
- Las dependencias externas (TMDB, Trakt, almacenamiento, la hora) se sustituyen en las pruebas por versiones falsas detrás de sus contratos (`protocol`).
- La lógica vive en un paquete Swift local separado de la app, para que sus pruebas corran sin simulador.
- Pasa las pruebas del archivo que tocas a menudo, y todas al final de cada tarea.

## Código

- Código, nombres y comentarios en **inglés**. Textos de la app en **castellano**.
- Usa los términos de `CONTEXT.md` (glosario castellano ↔ inglés). Si falta uno, añádelo ahí en vez de inventar sinónimos.
- Funciones y tipos pequeños con un solo propósito. Nombres que explican qué hacen, sin abreviaturas.
- La app es delgada: muestra datos y pasa los toques a `CueKit`. Las reglas viven en `CueKit`.
- Sin `!` para forzar opcionales ni `try!`; los errores se tratan o se propagan.
- Sin dependencias de terceros dentro de la app; solo herramientas de desarrollo.
- Ninguna clave (TMDB, Trakt) entra en el repo, que es público.

## Decisiones

- Si una tarea depende de algo sin decidir (PRD §10.2, por ejemplo D-04 o D-07, o cualquier hueco del PRD), **para y pregunta a Àlex**. No supongas.
- Las decisiones difíciles de cambiar se apuntan como ADR en `docs/adr/`.

## Issues y documentos

- Especificaciones y tareas en GitHub Issues de `alopedev/cue`, con `gh`. Las tareas se enlazan a su especificación y entre sí con los bloqueos nativos de GitHub.
- Glosario en `CONTEXT.md` y decisiones difíciles de cambiar en `docs/adr/`, ambos en la raíz. Léelos antes de tocar un área; créalos cuando haga falta el primer término o la primera decisión.
