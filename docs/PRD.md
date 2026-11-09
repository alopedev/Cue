# PRD — Cue (nombre provisional)

**Versión:** 0.2 · Borrador
**Fecha:** 1 de noviembre de 2026
**Autor:** Àlex
**Estado:** Decisiones de alcance cerradas el 31/10 y el 1/11 de 2026; la escala de puntuación (D-08), el 07/11. Quedan abiertas las de la §10.2.

**Cambios respecto a la v0.1 (15/08/2026):**

- Cue ya no es solo de series: también incluye **películas**.
- La recomendación tiene en cuenta el **tiempo** disponible y el **mood**. El usuario la pide con un botón; la app no abre directamente con una propuesta.
- Se muestran **tres propuestas** a la vez. Si se descartan las tres, la sesión termina sin más propuestas.
- Si nada de la lista del usuario encaja, se propone **algo nuevo** de sus plataformas.
- Entra la **puntuación** y la **sincronización con Trakt** en ambos sentidos.
- Aparece el estado **«al día»** para las series en emisión que el usuario tiene al día.
- La app sigue el modo claro/oscuro del iPhone. El widget sale de la fase 1.
- En cada requisito se indica si es **[nuevo]**, **[cambiado]** o **[aplazado]** respecto a la v0.1.

Detalle de cada decisión: documento «Cue — Listado de funcionalidades» (https://claude.ai/artifact/8aMSRYkiHe7xWvEJeQcDNP). Es un documento histórico y privado: si no coincide con este PRD, manda el PRD.

---

## 0. Cómo usar este documento

Este documento tiene dos lectores: Àlex y un agente de codificación.

- Las secciones §1–§4 dan el marco. Léelas para entender por qué, no para implementar.
- La §6 es la única sección normativa. Cada requisito está en notación EARS y es verificable con un test. Si el código y la §6 discrepan, gana la §6.
- La §2 (no-objetivos) tiene el mismo peso normativo que la §6. Si algo no está en el alcance, no se implementa aunque parezca obvio o barato.
- Los requisitos marcados **[aplazado]** no se implementan en la fase 1.
- La §10 lista lo que aún no está decidido. Un agente que necesite una de esas respuestas **debe parar y preguntar**, no asumir.

Convención EARS empleada:

| Patrón | Forma |
|---|---|
| Ubicuo | El sistema deberá ⟨respuesta⟩ |
| Dirigido por evento | Cuando ⟨disparador⟩, el sistema deberá ⟨respuesta⟩ |
| Dirigido por estado | Mientras ⟨estado⟩, el sistema deberá ⟨respuesta⟩ |
| Comportamiento no deseado | Si ⟨condición⟩, entonces el sistema deberá ⟨respuesta⟩ |
| Opcional | Donde ⟨característica presente⟩, el sistema deberá ⟨respuesta⟩ |

---

## 1. Problema y tesis

### 1.1 El problema

Existe un mercado maduro de aplicaciones para llevar el control de lo que ves: registrar episodios, marcar progreso, guardar valoraciones. Todas son **retrospectivas**. Ninguna resuelve el momento que realmente duele: son las 22:10, tienes una ventana de tiempo concreta, te apetece algo concreto y no sabes qué poner.

El coste de ese momento está medido, aunque con datos que conviene tratar con cautela: Nielsen situó la búsqueda media en algo más de siete minutos, con un 21 % de usuarios que abandonan sin ver nada cuando no saben qué quieren. Ese estudio es de 2019 y las cifras posteriores que circulan proceden de fuentes secundarias que se citan entre sí sin origen verificable. **No usar ninguna de estas cifras en material público sin volver a verificarlas.**

### 1.2 La tesis

Cue es una app para llevar el control de tus series y películas que, cuando se lo pides, te dice qué ver **según el tiempo que tienes y tu mood**.

El diferenciador no es catalogar mejor: es que el sistema conoce tu lista, tu ritmo y tus plataformas, y con eso emite **tres recomendaciones explicadas** en lugar de un catálogo ordenado. La explicación no es adorno; es el producto. Un motor que no puede justificarse en una línea no está recomendando, está adivinando.

### 1.3 Por qué es defendible

Un recomendador sobre el catálogo mundial es replicable con un prompt: cualquiera puede pedir a un asistente genérico una película de noventa minutos disponible en su plataforma. Un recomendador que parte de **tu propia lista** requiere datos que solo existen dentro del producto: qué dejaste a medias, cuándo, a qué ritmo ibas, qué puntuaste y qué rechazaste.

Por eso Cue propone primero de la lista del usuario, y solo recurre al catálogo general cuando nada de la lista encaja (RF-14).

---

## 2. No-objetivos

Esta sección es normativa. Nada de lo siguiente entra en la v1.

| No-objetivo | Motivo |
|---|---|
| Libros, videojuegos, pódcast | Duraciones y consumo incomparables con series y películas. |
| Funciones sociales: seguir usuarios, feed, reseñas públicas | Requieren masa crítica que un producto en solitario no puede generar. |
| Colecciones o listas libres definidas por el usuario | La biblioteca v1 se organiza por estado, no por gusto. |
| Notas y diario de visionado | Territorio de la competencia; no alimentan el motor. (La puntuación **sí** entra: RF-44.) |
| Rachas, insignias, niveles o cualquier mecánica de racha | Convierten el ocio en obligación y contradicen el ángulo de deuda de ocio (§9.2). |
| Notificaciones de cualquier tipo | Avisar para que el usuario vuelva es una mecánica de reenganche (§9.2). |
| Reproducción o enlaces directos a las plataformas | TMDB no los suministra (§8.1). Un servicio adicional podría darlos en el futuro. |
| Android, web, iPad, visionOS | iPhone únicamente en v1. |
| Cuenta de usuario propia o servidor propio | Persistencia local con sincronización del sistema. Trakt es un servicio externo opcional del usuario, no un servidor de Cue. |
| Marcado automático de episodios vistos | El usuario es responsable de su archivo. El sistema detecta desfase y pregunta, nunca decide. Las marcas que llegan de Trakt las hizo el propio usuario en otra app. |
| Widget de pantalla de inicio | Aplazado a después de la fase 1 (decisión del 31/10/2026). |

---

## 3. Usuario y momento de uso

**Usuario primario.** Persona que sigue entre tres y ocho series a la vez y tiene películas pendientes, con dos o más servicios de streaming, que consume por la noche en sesiones de entre cuarenta minutos y dos horas.

**Momento de uso canónico.** Entre semana, después de cenar, entre las 21:30 y las 23:30. Luz ambiental baja. Usuario cansado, con poca disposición a introducir datos y ninguna a navegar un catálogo.

**Consecuencias de diseño derivadas del momento:**

- La app sigue el modo claro u oscuro del iPhone (decisión del 31/10/2026). El diseño debe funcionar bien en oscuro, porque será lo habitual a esas horas.
- Ninguna interacción crítica exige teclado. Tiempo y mood se eligen con botones.
- Pedir una recomendación cuesta como máximo tres toques: tiempo, mood y botón. Si el último tiempo y mood sirven, uno solo.

**Anti-usuario.** El coleccionista que quiere catalogar exhaustivamente lo que ha visto en quince años. Está bien servido por la competencia y sus necesidades desvían el producto hacia el archivo.

---

## 4. Modelo de dominio

Entidades mínimas. Un agente debe implementar exactamente estas y preguntar antes de añadir otras.

### 4.1 Entidades de catálogo (origen externo, solo lectura)

**Serie** — identificador externo, título, año, número de temporadas, estado de emisión (en emisión / finalizada / cancelada), géneros, palabras clave, imagen de portada.

**Temporada** — serie a la que pertenece, número, número de episodios.

**Episodio** — temporada a la que pertenece, número, título, duración en minutos, fecha de emisión.

**Película** **[nuevo]** — identificador externo, título, año, duración en minutos, géneros, palabras clave, imagen de portada.

**Disponibilidad** — serie o película, proveedor de streaming, país, tipo de acceso (suscripción / alquiler / compra).

### 4.2 Entidades de configuración (definidas por la app)

**Mood** **[nuevo]** — nombre visible y los géneros (y, donde haga falta, palabras clave) de TMDB que agrupa, por separado para series y para películas. Lista inicial:

| Mood | Películas | Series |
|---|---|---|
| Reír | Comedy | Comedy |
| Tensión | Thriller, Crime, Mystery | Crime, Mystery |
| Romántica | Romance | Palabras clave de TMDB (las series no tienen este género) |
| Drama | Drama | Drama |
| Acción | Action, Adventure | Action & Adventure |
| Otros mundos | Science Fiction, Fantasy | Sci-Fi & Fantasy |
| Miedo | Horror | Palabras clave de TMDB (las series no tienen este género) |
| Algo ligero | Family, Animation | Family, Animation |
| Aprender algo | Documentary, History | Documentary |
| Me da igual | todos | todos |

Los géneros de series están comprobados en la documentación de TMDB; los de películas deben comprobarse contra la API al implementar. Las palabras clave concretas de «romántica» y «miedo» están por definir (D-11).

### 4.3 Entidades de usuario (origen local, lectura y escritura)

**SeguimientoSerie** **[cambiado]** — serie, estado (`pendiente` | `viendo` | `al_día` | `pausada` | `abandonada` | `terminada`), fecha de alta, fecha del último episodio marcado, episodio actual.

**SeguimientoPelícula** **[nuevo]** — película, estado (`pendiente` | `vista` | `descartada`), fecha de alta, fecha de visionado.

**MarcaEpisodio** **[cambiado]** — episodio, fecha y hora de marcado, origen (`manual` | `trakt` | `reconciliado`).

**Puntuación** **[nuevo]** — serie o película, valor de 1 a 10 (D-08), fecha, origen (`manual` | `trakt`).

**Plataforma** — proveedor de streaming que el usuario declara tener contratado.

**Ajustes** **[nuevo]** — país (por defecto, la región del iPhone), último tiempo elegido, último mood elegido, cuenta de Trakt conectada (sí/no).

**Veto** **[aplazado]** — regla dura declarada por el usuario. Tipos: género excluido, duración máxima de episodio, número máximo de temporadas para empezar algo nuevo.

**Decisión** **[cambiado]** — instante, ventana de tiempo aplicada, mood aplicado, y las tres propuestas. Cada propuesta guarda: título propuesto (episodio de una serie o película), procedencia (`lista` | `nuevo`), señales que la motivaron con su peso y desenlace (`aceptada` | `rechazada` | `sin_respuesta`).

**Rechazo** — propuesta asociada, motivo (`hoy_no` | `demasiado_larga` | `perdí_el_hilo` | `ya_no_me_interesa`), instante.

### 4.4 Invariantes

- Una serie tiene como máximo un SeguimientoSerie por usuario; una película, como máximo un SeguimientoPelícula. (Con CloudKit no hay restricción de unicidad: hay que garantizarlo al guardar y deduplicar al sincronizar.)
- El episodio actual de un SeguimientoSerie es siempre el siguiente sin marcar en orden de emisión.
- Una serie está `al_día` si y solo si está en emisión, el usuario ha marcado todos los episodios emitidos y queda alguno por emitir.
- Una Decisión conserva las señales y sus pesos **en el momento de emitirse**. Recalcular a posteriori invalida el análisis de rechazos.

---

## 5. Alcance

### 5.1 Fase 1 — tanda A

1. Primer arranque: plataformas, añadir series y películas con una rejilla rápida, indicar por dónde vas.
2. Añadir títulos y cambiar plataformas en cualquier momento.
3. Biblioteca en rejilla de portadas, por estados, con ficha de cada título.
4. Marcar episodios y películas como vistos, con deshacer.
5. Puntuar series y películas.
6. «Esta noche»: elegir tiempo y mood, pulsar el botón y recibir tres propuestas explicadas.
7. Descartar con motivo.
8. Funcionamiento sin conexión y sincronización con iCloud.

### 5.2 Fase 1 — tanda B

9. Conexión con Trakt y sincronización en ambos sentidos.

### 5.3 Después de la fase 1

Widget, vetos, aprendizaje a partir de los rechazos, señales de ritmo y franja horaria, reconciliación de posición, propuesta de prueba durante el primer arranque, explicación redactada por un modelo de lenguaje.

**Fuera:** todo lo listado en §2.

---

## 6. Requisitos funcionales

### 6.1 Primer arranque

**RF-01** — Al abrir la aplicación por primera vez, el sistema deberá presentar la selección de plataformas de streaming antes que cualquier otra pantalla.

**RF-02** — El sistema deberá permitir completar la selección de plataformas sin introducir texto.

**RF-03** **[aplazado]** — Cuando el usuario haya seleccionado cuatro series activas durante el alta, el sistema deberá mostrar una decisión preliminar antes de continuar con las restantes.

**RF-04** — Al capturar la posición de una serie, el sistema deberá preseleccionar el último episodio emitido como posición actual.

**RF-05** **[cambiado]** — El sistema deberá permitir marcar una serie o una película como no empezada durante el alta, registrándola con estado `pendiente`.

**RF-06** **[cambiado]** — Si el usuario finaliza el alta con menos de tres títulos en estado `viendo` o `pendiente`, entonces el sistema deberá solicitar al menos uno más antes de mostrar la pantalla principal.

**RF-07** **[cambiado]** — Donde el usuario disponga de cuenta de Trakt, el sistema deberá ofrecer conectarla durante el alta, como atajo opcional (ver §6.9). *(Tanda B.)*

**RF-08** — El sistema no deberá solicitar permiso de notificaciones en ningún momento.

**RF-09** **[nuevo]** — El sistema deberá presentar en el alta una rejilla de portadas de series y películas populares en el país del usuario, donde un toque añade el título, junto con un buscador.

### 6.2 Motor de decisión — petición

**RF-41** **[nuevo]** — La pantalla «Esta noche» deberá mostrar un selector de tiempo (30, 45, 60, 90 y 120 minutos), un selector de mood (§4.2) y un botón para pedir la recomendación, con el último tiempo y el último mood preseleccionados.

**RF-42** **[nuevo]** — El sistema no deberá emitir ninguna propuesta hasta que el usuario pulse el botón de recomendación.

**RF-19** **[cambiado]** — El sistema deberá mostrar las propuestas en menos de 300 ms desde que se pulsa el botón, empleando el estado persistido y sin esperar a peticiones de red.

**RF-20** — Mientras el dispositivo no disponga de conexión, el sistema deberá emitir decisiones con los datos de catálogo almacenados localmente.

### 6.3 Motor de decisión — filtros duros

**RF-10** — El sistema deberá excluir de toda propuesta los títulos sin disponibilidad en ninguna de las plataformas declaradas por el usuario.

**RF-11** **[cambiado]** — El sistema deberá excluir de toda propuesta los episodios y las películas cuya duración supere la ventana de tiempo elegida. Una película solo se propone si cabe entera.

**RF-43** **[nuevo]** — Mientras el mood elegido no sea «me da igual», el sistema deberá excluir de toda propuesta los títulos que no pertenezcan a ese mood según §4.2.

**RF-12** **[aplazado]** — El sistema deberá excluir de toda propuesta los títulos que incumplan cualquier veto activo.

**RF-13** **[cambiado]** — El sistema deberá excluir de toda propuesta las series en estado `al_día`, `abandonada` o `terminada`, y las películas en estado `vista` o `descartada`.

**RF-14** **[cambiado]** — Si tras aplicar los filtros duros quedan menos de tres candidatos de la lista del usuario, entonces el sistema deberá completar las propuestas con títulos que el usuario no sigue, disponibles en sus plataformas y que cumplan los filtros, marcados como «nuevo para ti».

**RF-58** **[nuevo]** — Si tras aplicar RF-14 no queda ningún candidato, entonces el sistema deberá informar de la ausencia de propuesta e indicar qué filtro la ha causado (tiempo, mood o plataformas).

### 6.4 Motor de decisión — ordenación

**RF-15** — El sistema deberá ordenar los candidatos mediante una función determinista de las señales definidas en §6.5.

**RF-16** — El sistema no deberá emplear un modelo de lenguaje para ordenar candidatos.

**RF-45** **[nuevo]** — El sistema deberá ordenar primero los candidatos de la lista del usuario y después los «nuevo para ti».

**RF-26** **[cambiado]** — El sistema deberá presentar exactamente tres propuestas a la vez, o menos si no hay candidatos suficientes.

**RF-18** — El sistema deberá presentar junto a cada propuesta una explicación de una sola frase construida a partir de las dos señales de mayor peso en esa propuesta. En la fase 1 la frase se construye con plantillas.

**RF-17** **[aplazado]** — Donde se emplee un modelo de lenguaje para redactar la explicación, el sistema deberá almacenar el resultado en caché asociado a la combinación de señales, y no deberá invocarlo de nuevo para una combinación ya redactada.

### 6.5 Señales de ordenación

**RF-21** **[cambiado]** — El sistema deberá calcular la puntuación de cada candidato a partir de, como mínimo, las siguientes señales:

| Señal | Aplica a | Comportamiento | Fase |
|---|---|---|---|
| Días desde el último episodio marcado | Series | Curva no lineal: máximo entre 2 y 7 días; penalización creciente a partir de 30; penalización fuerte a partir de 60 | 1 |
| Encaje en la ventana | Ambas | Máximo cuando el título ocupa entre el 70 % y el 100 % de la ventana, o cuando caben dos episodios completos | 1 |
| Cierre inminente | Series | Bonificación cuando restan uno o dos episodios para terminar temporada o serie | 1 |
| Urgencia de spoiler | Series | Bonificación cuando el episodio pendiente se emitió en los últimos siete días | 1 |
| Tiempo en pendientes | Películas | Bonificación creciente cuanto más tiempo lleva la película en `pendiente` | 1 |
| Afinidad por puntuación | Ambas | Bonificación a títulos cuyos géneros coinciden con los de títulos bien puntuados por el usuario | 1 |
| Ritmo histórico del usuario con esa serie | Series | Bonificación proporcional a la frecuencia media de visionado previa | Después |
| Franja horaria | Ambas | Ajuste según coincidencia con el patrón histórico de visionado del usuario en ese día y hora | Después |

**RF-22** — Mientras el sistema disponga de menos de tres semanas de historial para un usuario, deberá calcular la puntuación empleando únicamente las señales de la fase 1.

**RF-23** — El sistema deberá poder proponer el inicio de una serie en estado `pendiente`, aplicando una penalización por coste de inicio y ninguna penalización por coste de recuerdo.

### 6.6 Rechazo y aprendizaje

**RF-24** — Cuando el usuario rechace una propuesta, el sistema deberá registrar un Rechazo con su motivo y las señales de la propuesta asociada.

**RF-25** **[aplazado]** — Cuando se registre un rechazo, el sistema deberá reducir el peso de las señales que motivaron esa propuesta concreta para ese usuario, además de penalizar el título propuesto.

**RF-27** **[cambiado]** — Si el usuario rechaza las tres propuestas, entonces el sistema deberá terminar la sesión de recomendación con un mensaje, sin presentar más propuestas ni alternativas, hasta que el usuario vuelva a pulsar el botón con otro tiempo u otro mood.

**RF-46** **[nuevo]** — El sistema no deberá obligar al usuario a aceptar ni rechazar ninguna propuesta: puede salir de la pantalla en cualquier momento, y esas propuestas quedan como `sin_respuesta`.

**RF-28** — El sistema no deberá volver a proponer un título rechazado con motivo `ya_no_me_interesa` hasta que el usuario lo reactive explícitamente desde la biblioteca.

**RF-29** — Cuando el motivo del rechazo sea `hoy_no`, el sistema no deberá aplicar penalización persistente al título.

### 6.7 Marcado, puntuación y frescura del estado

**RF-30** **[cambiado]** — El sistema deberá permitir marcar un episodio o una película como vistos con una única interacción desde la pantalla «Esta noche» y desde la biblioteca.

**RF-33** — El sistema deberá permitir deshacer el marcado durante los diez segundos siguientes.

**RF-44** **[nuevo]** — Cuando el usuario termine una serie o vea una película, el sistema deberá ofrecer puntuarla, sin obligar a hacerlo. La puntuación podrá cambiarse después desde la ficha.

**RF-47** **[nuevo]** — Cuando se emita un episodio nuevo de una serie en estado `al_día`, el sistema deberá pasarla a `viendo` sin intervención del usuario.

**RF-48** **[nuevo]** — Cuando el usuario marque el último episodio emitido de una serie en emisión que tiene episodios por emitir, el sistema deberá pasarla a `al_día`.

**RF-31** **[aplazado]** — Si una serie en estado `viendo` acumula un intervalo sin marcar superior a tres veces el intervalo medio histórico del usuario con esa serie, entonces el sistema deberá solicitar confirmación de la posición actual antes de incluirla en una propuesta.

**RF-32** **[aplazado]** — Cuando el usuario confirme o corrija la posición mediante una solicitud de reconciliación, el sistema deberá registrar las marcas resultantes con origen `reconciliado`.

### 6.8 Biblioteca y ajustes

**RF-34** **[cambiado]** — El sistema deberá presentar la biblioteca como una rejilla de portadas agrupada por estado, con `viendo` como agrupación por defecto, e incluyendo películas.

**RF-35** **[cambiado]** — El sistema deberá mostrar en cada portada de una serie en estado `viendo` una barra de progreso, y en su ficha el episodio actual, los episodios restantes y el tiempo restante estimado.

**RF-36** — El sistema deberá permitir cambiar el estado de un título a `abandonada` (series) o `descartada` (películas) solicitando un motivo, con la opción de omitirlo.

**RF-37** — El sistema deberá mostrar en la cabecera de la biblioteca el tiempo total estimado para ponerse al día con todas las series en estado `viendo`.

**RF-49** **[nuevo]** — El sistema deberá permitir buscar y añadir series y películas desde la biblioteca en cualquier momento.

**RF-50** **[nuevo]** — El sistema deberá permitir cambiar las plataformas contratadas y el país desde los ajustes.

**RF-51** **[nuevo]** — Al abrir la aplicación por primera vez, el sistema deberá tomar como país el de la región del iPhone, sin preguntar.

### 6.9 Sincronización con Trakt *(tanda B)*

**RF-52** **[nuevo]** — Donde el usuario conecte su cuenta de Trakt, el sistema deberá importar su historial de visionado, su lista de pendientes y sus puntuaciones.

**RF-53** **[nuevo]** — Mientras la cuenta de Trakt esté conectada, el sistema deberá enviar a Trakt cada marca de visto y cada puntuación hecha en Cue.

**RF-54** **[nuevo]** — Mientras la cuenta de Trakt esté conectada, el sistema deberá traer los cambios hechos en Trakt al abrir la aplicación, registrando las marcas con origen `trakt`.

**RF-55** **[nuevo]** — Si un envío a Trakt falla, entonces el sistema deberá guardarlo y reintentarlo más tarde, sin bloquear al usuario.

**RF-56** **[nuevo]** — El sistema deberá reconstruir la posición de cada serie a partir del historial de Trakt, sin depender de su función «Up Next» (§8.2).

**RF-57** **[nuevo]** — El sistema deberá permitir desconectar la cuenta de Trakt conservando todos los datos locales.

### 6.10 Widget **[aplazado]**

**RF-38** — El widget deberá mostrar el título y la duración de la propuesta vigente.

**RF-39** — El widget deberá actualizarse al marcarse un episodio o al registrarse un rechazo.

**RF-40** — Si no existe decisión válida, entonces el widget deberá mostrar un estado neutro sin proponer contenido.

---

## 7. Requisitos no funcionales

### 7.1 Rendimiento percibido

**RNF-01** — Ninguna transición deberá bloquear la interacción. Todas las transiciones deberán ser interrumpibles.

**RNF-02** — El sistema no deberá incluir animaciones de celebración salvo al completar una temporada, una serie o una película.

**RNF-03** **[cambiado]** — El tiempo entre la apertura de la aplicación y la pantalla «Esta noche» lista para usar no deberá superar los 500 ms en un dispositivo compatible con la versión mínima soportada.

### 7.2 Retorno táctil

**RNF-04** — El sistema deberá emitir retorno háptico únicamente como respuesta a una acción iniciada por el usuario.

**RNF-05** **[cambiado]** — La app solo deberá añadir háptica propia en tres eventos: marcado de visto, confirmación de descarte y fin de temporada, serie o película. Deberá respetar el ajuste de vibraciones del sistema.

**RNF-06** — El sistema no deberá emplear el retorno háptico como único canal de confirmación de ninguna acción.

**RNF-07** — El sistema deberá emplear el patrón del sistema correspondiente al significado del evento, sin reutilizar patrones de aviso para confirmaciones.

**RNF-08** — Toda háptica deberá verificarse en dispositivo físico. El simulador no la reproduce.

### 7.3 Presentación

**RNF-09** **[cambiado]** — El sistema deberá seguir el ajuste de modo claro u oscuro del iPhone.

**RNF-10** — El sistema no deberá superponer texto de párrafo sobre materiales translúcidos. El material translúcido queda restringido a controles flotantes.

**RNF-11** **[cambiado]** — Los botones propios de Cue deberán tener forma de cápsula; las tarjetas, esquinas redondeadas concéntricas. Los controles del sistema no se reestilizan.

**RNF-12** — El sistema deberá respetar la preferencia de movimiento reducido del sistema, sustituyendo transiciones por cambios de opacidad.

### 7.4 Datos y privacidad

**RNF-13** — El sistema deberá persistir todos los datos de usuario en el dispositivo, sincronizados mediante iCloud.

**RNF-14** — El sistema no deberá transmitir el historial de visionado a ningún servidor propio. Solo se envía a Trakt si el usuario lo conecta.

**RNF-15** **[cambiado]** — El sistema deberá mostrar el logotipo de TMDB, la frase de que Cue no está avalado por TMDB y la atribución a JustWatch en las pantallas que exigen sus condiciones (§8.1).

**RNF-18** **[nuevo]** — El sistema no deberá conservar datos de catálogo obtenidos de TMDB durante más de 6 meses sin refrescarlos.

### 7.5 Accesibilidad

**RNF-16** — La explicación de cada propuesta deberá ser accesible mediante lector de pantalla como texto continuo.

**RNF-17** — El sistema deberá soportar tamaños de texto dinámicos sin truncar la explicación de la propuesta.

---

## 8. Dependencias externas y riesgos verificados

### 8.1 Catálogo y disponibilidad

Proveedor elegido (confirmado el 1/11/2026): TMDB, que sirve los datos de disponibilidad por país y proveedor a través de su acuerdo con JustWatch.

**Restricciones verificadas:**
- No se suministran enlaces directos a las plataformas.
- La atribución a JustWatch es obligatoria y su incumplimiento conlleva revocación del acceso.
- Las condiciones de la API ([API Terms of Use](https://www.themoviedb.org/api-terms-of-use), revisadas el 1/11/2026) exigen el logotipo de TMDB y la frase de que la app no está avalada por TMDB.
- Los datos obtenidos no pueden guardarse en caché más de 6 meses (RNF-18).
- **Uso comercial:** la licencia estándar no lo permite. Cobrar a los usuarios por una app que usa TMDB requiere un acuerdo escrito con TMDB, que puede incluir cuotas. Hay que resolverlo antes de publicar si Cue es de pago (D-06).

**Alternativas evaluadas el 1/11/2026 y descartadas como base:** TVDB (cada usuario paga 12 $ al año, o contrato negociado), Watchmode (el plan gratuito es no comercial y sin enlaces directos; el de pago empieza en 349 $ al mes). Streaming Availability API ofrece enlaces directos y es candidata para añadirlos más adelante encima de TMDB; sus precios de pago no están verificados.

**Limitación verificada de los géneros:** en TMDB, las series no tienen los géneros Thriller, Romance ni Horror. Los moods agrupan géneros y palabras clave (§4.2).

### 8.2 Sincronización con Trakt

Proveedor: Trakt, API v2 con OAuth 2.0, con acceso a historial, lista de pendientes, puntuaciones y progreso.

**Restricción verificada:** la documentación de Trakt advierte de que el endpoint de «Up Next» puede no estar disponible o devolver datos incompletos en aplicaciones públicas. La posición actual de cada serie debe reconstruirse desde el historial (RF-56).

**Riesgo sin verificar:** según una fuente no oficial (el autor del plugin Traktivity), desde mediados de 2026 solo las cuentas VIP de Trakt pueden crear una aplicación de API. Esto afectaría al desarrollador, no a los usuarios: las apps existentes sincronizan con cuentas gratuitas (comprobado por Àlex con Sequel el 1/11/2026). Debe confirmarse al dar de alta la aplicación en Trakt.

**Riesgo de producto:** la base de usuarios de Trakt es un nicho de usuarios avanzados. Las cuentas gratuitas de Trakt tienen límites en sus listas que pueden limitar lo que se sincroniza.

### 8.3 Plataforma

iPhone con iOS 27. Lenguaje de interfaz: SwiftUI. El lenguaje visual del sistema es el material translúcido introducido en iOS 26, con los ajustes de legibilidad incorporados posteriormente. Cue tiene identidad visual propia (dirección «Táctil», decidida el 31/10/2026) dentro de las buenas prácticas de Apple.

**Riesgo:** el autor no tiene experiencia previa en Swift. Se recomienda no arrancar por el motor sino por el modelo de datos y la biblioteca. La fase 1 ha crecido (películas, mood, puntuación y Trakt), por eso se divide en dos tandas (§5).

---

## 9. Métricas

### 9.1 Métricas de éxito

| Métrica | Dirección | Motivo |
|---|---|---|
| Tasa de aceptación de alguna de las tres propuestas | ↑ | Mide la calidad del motor |
| Segundos entre pulsar el botón y aceptar una propuesta | ↓ | Es la propuesta de valor literal |
| Sesiones de recomendación que terminan en propuesta aceptada | ↑ | Mide utilidad, no atención |
| Episodios y películas marcados por semana y usuario | ↑ | Único indicador fiable de frescura del dato |
| Títulos cerrados o abandonados explícitamente | ↑ | Indica que el archivo refleja la realidad |
| Proporción de propuestas aceptadas que son «nuevo para ti» | — | Indica si la lista del usuario se queda corta |

### 9.2 Métricas explícitamente rechazadas

**Tiempo de permanencia en la aplicación.** Su aumento indica fallo del producto: si el usuario está en Cue, no está viendo nada.

**Sesiones diarias.** El producto se usa cuando hace falta. Aumentarlas implicaría introducir mecánicas de reenganche incompatibles con §2.

### 9.3 Marco de motivación

La aplicación opera íntegramente en la fase anticipatoria del ciclo de recompensa: el disfrute ocurre fuera del producto. El objetivo del diseño es transferir la motivación hacia el contenido, no retenerla en la aplicación. De ahí que la explicación de la propuesta sea la pieza de mayor inversión de diseño y que las mecánicas de retención queden excluidas.

Este marco es una guía de diseño, no evidencia empírica de que el enfoque funcione.

---

## 10. Decisiones

### 10.1 Cerradas

| # | Decisión | Resultado | Fecha |
|---|---|---|---|
| D-01 | Variante de la pantalla de decisión | Tres propuestas a la vez | 01/11/2026 |
| D-02 | Variante de alta | Rejilla rápida | 01/11/2026 |
| D-03 | Variante de biblioteca | Rejilla de portadas; el tiempo restante va en la ficha | 01/11/2026 |
| D-05 | Qué pasa tras rechazar las tres propuestas | Termina ahí, sin alternativa | 01/11/2026 |
| D-06 | Modelo de negocio | Se decide antes de publicar; no bloquea la fase 1 | 01/11/2026 |
| D-08 | Escala de puntuación | 1–10, la misma que Trakt, para no convertir | 07/11/2026 |
| — | Películas | Entran en la fase 1 | 01/11/2026 |
| — | Origen de las propuestas | La lista del usuario primero, luego «nuevo para ti» | 01/11/2026 |
| — | Trakt | Sincronización en ambos sentidos, fase 1 (tanda B) | 01/11/2026 |
| — | Proveedor de datos | TMDB | 01/11/2026 |
| — | Tema, botones, háptica | Seguir el iPhone y las recomendaciones de Apple | 31/10/2026 |
| — | Widget | Fuera de la fase 1 | 31/10/2026 |

### 10.2 Abiertas

Un agente que necesite alguna de estas respuestas debe detenerse y preguntar.

| # | Decisión | Opciones | Recomendación |
|---|---|---|---|
| D-04 | Pesos iniciales de las señales de §6.5, incluido cómo comparar series con películas | — | Sin resolver. Requiere calibración manual con datos reales |
| D-07 | Nombre del producto | — | «Cue» es provisional |
| D-09 | Conflictos de sincronización con Trakt | El cambio más reciente gana / Trakt gana / Cue gana | El más reciente gana; una sincronización nunca borra una marca de visto |
| D-10 | Cuántas películas o series populares muestra la rejilla del alta | — | Sin resolver |
| D-11 | Palabras clave de TMDB para los moods «romántica» y «miedo» en series | — | Sin resolver. Probar con datos reales |

---

## 11. Glosario

**Lista del usuario** — conjunto de series en estado `viendo` o `pendiente` y películas en estado `pendiente`.

**Ventana** — minutos disponibles elegidos por el usuario para la sesión actual.

**Mood** — tipo de contenido que apetece, elegido por el usuario; agrupa géneros de TMDB.

**Propuesta** — título concreto (episodio de una serie o película) emitido por el motor, con su explicación.

**Decisión** — conjunto de las tres propuestas emitidas al pulsar el botón, con el tiempo y el mood aplicados.

**Nuevo para ti** — propuesta de un título que no está en la lista del usuario.

**Al día** — serie en emisión de la que el usuario ha visto todo lo emitido.

**Señal** — variable de entrada de la función de ordenación.

**Filtro duro** — condición binaria que excluye un candidato con independencia de su puntuación.

**Reconciliación** — solicitud de confirmación de posición cuando el sistema sospecha que el estado registrado no refleja la realidad.

**Deuda de ocio** — tiempo acumulado necesario para completar todas las series en curso.
