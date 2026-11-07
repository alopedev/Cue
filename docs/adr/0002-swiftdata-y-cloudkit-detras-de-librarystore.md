# 0002 · SwiftData y CloudKit detrás de `LibraryStore`

- Estado: aceptada
- Fecha: 07/11/2026

## Contexto

Los datos del usuario (seguimientos, marcas, puntuaciones, decisiones, rechazos y ajustes) se guardan en el iPhone y se sincronizan por iCloud entre sus dispositivos, sin servidor propio (PRD §7.4). CloudKit no admite restricciones de unicidad, y el PRD exige como mucho un seguimiento por serie o película (§4.4).

## Decisión

- La versión real de `LibraryStore` usa SwiftData con sincronización CloudKit.
- Los modelos de SwiftData (`@Model`) son privados del adaptador. Hacia fuera, `LibraryStore` solo entrega y recibe los tipos de valor de `Domain`.
- La unicidad se garantiza en el contrato: guardar un seguimiento o una puntuación de un título que ya existe lo sustituye. El adaptador además elimina duplicados que lleguen al sincronizar, con su propia prueba.
- `settings()` devuelve `nil` en el primer arranque; así la app sabe que debe mostrar la elección de plataformas (RF-01).

## Alternativas descartadas

- **Core Data con CloudKit.** Más código para lo mismo.
- **GRDB + CKSyncEngine.** Más control sobre la sincronización, pero bastante más trabajo y una dependencia de terceros.

## Consecuencias

- Si SwiftData se queda corto (por ejemplo, con los duplicados), se cambia el adaptador sin tocar la lógica ni las pantallas.
- Las pruebas de la lógica usan `InMemoryLibraryStore`, que cumple las mismas reglas de unicidad.
- La sincronización con iCloud necesita la cuenta de pago de Apple Developer (antes de H4).
