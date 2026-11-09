# 0001 · Arquitectura hexagonal con la lógica en un paquete local

- Estado: aceptada
- Fecha: 07/11/2026

## Contexto

Cue depende de tres servicios externos (TMDB, iCloud y Trakt) y de la hora. La lógica (reglas del dominio y motor de «Esta noche») tiene que probarse rápido, sin red y sin simulador, y varios agentes deben poder trabajar a la vez sin pisarse. El archivo del proyecto de Xcode (`.pbxproj`) se rompe con facilidad si lo tocan dos a la vez.

## Decisión

- Toda la lógica vive en el paquete Swift local `CueKit`. La app de Xcode solo muestra datos y pasa los toques a `CueKit`.
- La lógica habla con el exterior solo a través de cuatro contratos (`protocol`): `CatalogProvider`, `LibraryStore`, `HistorySync` y `Clock`.
- Cada contrato tiene una versión real (adaptador: TMDB, SwiftData con iCloud, Trakt, reloj del sistema) y una versión falsa en memoria para las pruebas y los datos de ejemplo.
- Dentro de `CueKit` el código se ordena en carpetas: `Domain` (tipos del glosario), `Contracts`, `Adapters` y `Fakes`. De momento es un solo target; se separará en targets (`Domain`, `Engine`…) cuando un bloque lo necesite, sin cambiar los contratos.
- Los tipos de `Domain` son valores (`struct` y `enum`) inmutables, `Sendable` y sin dependencias de frameworks de Apple más allá de `Foundation`.

## Alternativas descartadas

- **Todo dentro del proyecto de Xcode.** Las pruebas necesitarían simulador y cada archivo nuevo tocaría el `.pbxproj`.
- **MVVM con la lógica en las pantallas.** El motor y las reglas no se podrían probar sin red ni iCloud.
- **Un target por capa desde el principio.** Hoy no hay código que separar; obliga a tocar `Package.swift` antes de hacer falta.

## Consecuencias

- Cambiar TMDB, iCloud o Trakt por otra cosa solo toca su adaptador.
- Un cambio en un contrato afecta a todos los flujos: se hace en una PR pequeña aparte y los demás se actualizan antes de seguir (plan, §6).
- Las versiones falsas forman parte de `CueKit` (no de las pruebas) para que la app pueda arrancar con datos de ejemplo en el bloque 1.
