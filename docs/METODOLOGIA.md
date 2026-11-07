# Cómo se programa Cue

Decidido por Àlex en una entrevista el 01/11/2026. Este documento explica el método en lenguaje llano. Las reglas exactas para los agentes están en [`CLAUDE.md`](../CLAUDE.md).

## En una frase

Claude construye la app **por bloques**, siempre **con pruebas primero (TDD)**, con un **equipo de subagentes** que él coordina y revisa, y al final de cada bloque pasa una **ronda de calidad y seguridad**. Àlex prueba el resultado y da el «sí» final.

## Quién hace qué

| Quién | Qué hace |
| --- | --- |
| **Àlex** | Decide lo que no está decidido. Prueba cada bloque en el simulador o en su iPhone. Aprueba y fusiona cada PR. No necesita leer código. |
| **Claude orquestador** (sesión de Claude Code Desktop en el Mac de Àlex) | Planifica, reparte tareas a los subagentes, revisa su trabajo, pasa las revisiones y abre la PR. |
| **Subagentes** | Cada uno construye una tarea pequeña con TDD y devuelve el resultado al orquestador. |
| **Proyecto Cue en Claude** (los hilos en la nube) | Planificar, entrevistar y decidir. No construye: desde la nube no se puede compilar ni abrir el simulador. |

## Dónde se construye

En el Mac de Àlex (última versión de Xcode), en una sesión **local** de Claude Code Desktop abierta sobre este repo. Así Claude puede compilar, pasar las pruebas y usar el [panel de simulador de iOS](https://code.claude.com/docs/en/desktop-ios-simulator), que solo funciona en sesiones locales.

## El camino de cada bloque

Sigue el método de Matt Pocock ([mattpocock/skills](https://github.com/mattpocock/skills)):

1. **Entrevista** (`/grill-with-docs`): Claude pregunta hasta que no quede nada en el aire. Lo que se aclara se apunta en el glosario (`CONTEXT.md`) y, si es una decisión difícil de cambiar, en `docs/adr/`.
2. **Especificación** (`/to-spec`): la entrevista se convierte en una descripción del bloque, publicada como issue en GitHub.
3. **Tareas** (`/to-tickets`): el bloque se parte en tareas pequeñas. Cada tarea atraviesa la app de punta a punta (datos, lógica y pantalla) y dice qué otras tareas tienen que acabar antes. Van como issues en GitHub.
4. **Construcción**: el orquestador da cada tarea a un subagente, que la hace con `/tdd`: escribe una prueba que falla, escribe lo mínimo para que pase, ordena el código, y repite.
5. **Ronda de calidad y seguridad**: `/code-review` de Matt (¿sigue las normas del repo? ¿hace lo que pedía la especificación?) y `/security-review` de Claude Code (¿hay fallos de seguridad, por ejemplo claves mal guardadas?).
6. **PR**: con capturas del simulador. Àlex la prueba y la fusiona.

Cada 3 o 4 bloques, además, `/improve-codebase-architecture` para que el código no se enrede.

## Reglas acordadas

- **Un bloque = una funcionalidad que se puede probar = una PR.** Por ejemplo: «añadir una serie y verla en la biblioteca».
- **TDD estricto en la lógica**: biblioteca, reglas, recomendación, sincronización. Las **pantallas** se comprueban con capturas en el simulador y algunas pruebas que usan la app como una persona. No se escriben pruebas de relleno que no comprueban nada real (la propia skill `/tdd` de Matt lo advierte).
- **La lógica va separada de las pantallas**, en un paquete propio dentro del repo. Así sus pruebas tardan segundos y no necesitan el simulador.
- **Código en inglés; la app, en castellano.** El glosario `CONTEXT.md` dice cómo se llama cada idea en los dos idiomas (por ejemplo «Esta noche» = `Tonight`).
- **Subagentes: como mucho 6 a la vez** (decidido el 07/11/2026), y solo en tareas que no tocan los mismos archivos. Motivo: el archivo del proyecto de Xcode se rompe con facilidad si dos agentes lo cambian a la vez, y cada agente extra gasta más uso.
- **Una sola orden lo comprueba todo**: `scripts/verify.sh` revisa el formato, las normas de estilo, las pruebas y cuánto código cubren. Tiene que salir en verde antes de cada PR.
- **Revisión automática en GitHub**: cada PR pasa sola `scripts/verify.sh` en un Mac de GitHub. Si GitHub aún no tiene la versión de Xcode necesaria, se prueba solo en el Mac de Àlex hasta que la tenga.
- **Las tareas viven en GitHub Issues** del repo, enlazadas entre sí con sus bloqueos.
- **Si algo no está decidido, se pregunta.** Si una tarea choca con una decisión abierta del PRD (§10.2, por ejemplo D-04 o D-07), el agente se para y pregunta a Àlex. Nunca supone.
- **Un bloque está terminado** cuando: todas las pruebas pasan, las revisiones no encuentran fallos graves, la PR trae capturas y Àlex lo ha probado.
- **Àlex fusiona siempre.** Ningún agente fusiona PR.

## Orden de los primeros bloques

1. **Esqueleto y biblioteca con datos de prueba**: crear, ver y marcar series y películas, guardado en el móvil. No necesita claves ni cuentas, y fija el modelo de datos, que es lo que más cuesta cambiar después.
2. **Buscar títulos reales en TMDB.** Antes hará falta que Àlex cree una clave de TMDB; nunca se guarda en el repo, que es público.
3. **«Esta noche»**: la recomendación por tiempo y mood.

Después, el resto de la tanda A y la sincronización con Trakt (tanda B), según el [PRD](PRD.md).
