# Glosario de Cue

El vocabulario del producto en castellano (como lo dice el PRD y lo ve Àlex) y su nombre en el código (inglés). Si un concepto no está aquí, se añade antes de usarlo; no se inventan sinónimos.

Fuente: PRD §4 (modelo de dominio) y §11 (glosario).

## Catálogo

Datos que vienen de fuera (TMDB). La app solo los lee.

| Castellano | Código | Qué es |
|---|---|---|
| Serie | `Series` | Una serie del catálogo: título, año, temporadas, estado de emisión, géneros, palabras clave y portada. |
| Película | `Movie` | Una película del catálogo: título, año, duración, géneros, palabras clave y portada. |
| Título | `TitleID` | Una serie o una película, cuando algo vale para las dos (puntuación, disponibilidad). |
| Temporada | `Season` | Temporada de una serie: número y cuántos episodios tiene. |
| Episodio | `Episode` | Episodio de una temporada: número, título, duración y fecha de emisión. |
| Referencia de episodio | `EpisodeReference` | Cómo se señala un episodio: serie, temporada y número. Es lo mismo que usa Trakt. |
| Estado de emisión | `AiringStatus` | `airing` (en emisión), `ended` (finalizada), `canceled` (cancelada). |
| Género | `Genre` | Género de TMDB (Comedy, Drama…). Series y películas tienen listas distintas. |
| Palabra clave | `Keyword` | Etiqueta de TMDB más fina que el género. La usan algunos moods en series. |
| Disponibilidad | `Availability` | Dónde se puede ver un título en un país y cómo (`AccessType`). |
| Tipo de acceso | `AccessType` | `subscription` (suscripción), `rent` (alquiler), `buy` (compra). |
| Plataforma | `StreamingProvider` | Un servicio de streaming (Netflix, Max…). |
| País | `CountryCode` | Código de país de dos letras (ES, US…). La disponibilidad depende de él. |
| Ficha | `SeriesDetails`, `MovieDetails` | Todo lo que la app necesita de un título: datos, temporadas, episodios y disponibilidad. |

## Configuración

Definida por la app.

| Castellano | Código | Qué es |
|---|---|---|
| Mood | `Mood` | Tipo de contenido que apetece. Agrupa géneros (y a veces palabras clave) de TMDB, por separado para series y películas (`MoodCriteria`). «Me da igual» acepta todo. |
| Ventana | `TimeWindow` | Minutos disponibles que elige el usuario para esta sesión: 30, 45, 60, 90 o 120. |

## Usuario

Datos del usuario. Se guardan en el iPhone y en iCloud.

| Castellano | Código | Qué es |
|---|---|---|
| Seguimiento de serie | `SeriesTracking` | Lo que el usuario lleva de una serie: estado, fecha de alta, último episodio marcado y episodio actual. Como mucho uno por serie. |
| Seguimiento de película | `MovieTracking` | Lo mismo para una película: estado, fecha de alta y fecha de visionado. Como mucho uno por película. |
| Estado de serie | `SeriesStatus` | `pending` (pendiente), `watching` (viendo), `upToDate` (al día), `paused` (pausada), `abandoned` (abandonada), `finished` (terminada). |
| Estado de película | `MovieStatus` | `pending` (pendiente), `watched` (vista), `dismissed` (descartada). |
| Al día | `SeriesStatus.upToDate` | Serie en emisión de la que el usuario ha visto todo lo emitido y queda algo por emitir. |
| Episodio actual | `SeriesTracking.currentEpisode` | El siguiente episodio sin marcar, en orden de emisión. |
| Marca de visto | `EpisodeMark` | Un episodio marcado como visto, con fecha, hora y origen. |
| Origen de la marca | `MarkSource` | `manual`, `trakt` o `reconciled` (reconciliado). |
| Puntuación | `Rating` | Nota de 1 a 10 (`RatingValue`) que el usuario pone a una serie o película, con fecha y origen (`RatingSource`: `manual` o `trakt`). |
| Plataformas contratadas | `UserSettings.subscribedProviders` | Las plataformas que el usuario dice tener. |
| Ajustes | `UserSettings` | País, último tiempo y último mood elegidos, plataformas contratadas y si Trakt está conectado. |
| Lista del usuario | — | Series en `watching` o `pending` y películas en `pending`. De aquí salen primero las propuestas. |
| Deuda de ocio | — | Tiempo total que falta para ponerse al día con todas las series en `watching`. |

## Motor de decisión («Esta noche»)

| Castellano | Código | Qué es |
|---|---|---|
| Decisión | `Decision` | Lo que pasa al pulsar el botón: el instante, la ventana, el mood y las (hasta) tres propuestas. |
| Propuesta | `Proposal` | Un episodio o una película que el motor sugiere, con su frase de explicación, sus señales y su desenlace. |
| Lo propuesto | `ProposedItem` | Qué se propone: `episode` (un episodio de una serie) o `movie` (una película). |
| Procedencia | `ProposalOrigin` | `userList` (de la lista del usuario) o `newForYou` («nuevo para ti»). |
| Nuevo para ti | `ProposalOrigin.newForYou` | Propuesta de un título que el usuario no sigue. |
| Desenlace | `ProposalOutcome` | `accepted` (aceptada), `rejected` (rechazada), `noResponse` (sin respuesta). |
| Señal | `Signal` | Variable que el motor usa para ordenar candidatos (días desde el último episodio, encaje en la ventana…). |
| Señal con peso | `WeightedSignal` | Una señal con su valor y su peso **en el momento de emitir** la propuesta. No se recalcula después. |
| Filtro duro | — | Condición que deja fuera un candidato, puntúe lo que puntúe. |
| Candidato | — | Título que el motor considera antes de ordenar. |
| Rechazo | `Rejection` | El usuario dice que no a una propuesta, con un motivo y un instante. |
| Motivo del rechazo | `RejectionReason` | `notTonight` (hoy no), `tooLong` (demasiado larga), `lostTrack` (perdí el hilo), `notInterested` (ya no me interesa). |
| Reconciliación | — | Pedir al usuario que confirme por dónde va cuando el sistema sospecha que no está al día. Aplazada. |

## Contratos

Las piezas de fuera a las que la lógica habla sin saber cómo funcionan por dentro. Ver [ADR 0001](docs/adr/0001-arquitectura-hexagonal-en-paquete-local.md).

| Castellano | Código | Qué es |
|---|---|---|
| Catálogo | `CatalogProvider` | De dónde salen series y películas: buscar, populares por país y ficha. Versión real: TMDB. |
| Biblioteca | `LibraryStore` | Dónde se guardan los datos del usuario. Versión real: SwiftData con iCloud. |
| Sincronización de historial | `HistorySync` | Traer de Trakt y enviar a Trakt marcas, vistas y puntuaciones. |
| Reloj | `Clock` | La fecha y hora actuales. En las pruebas se fija a mano. |
| Versión falsa | `InMemory…`, `Fixed…`, `Fake…` | Versión de un contrato que guarda todo en memoria para las pruebas y los datos de ejemplo. |
