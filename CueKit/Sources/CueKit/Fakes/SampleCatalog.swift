import Foundation

/// Invented series and movies to try the app before the real catalog (TMDB) arrives.
///
/// Air dates are relative to `now`, so there is always something airing this week,
/// something finished and something canceled, whatever the day.
public enum SampleCatalog {
    /// Every sample title, series first, as the «add titles» grid shows them.
    public static func items(now: Date) -> [CatalogItem] {
        series(now: now).map { .series($0.series) } + movies.map { .movie($0.movie) }
    }

    /// A catalog with every sample title, listed as popular in every country.
    public static func provider(now: Date, country: CountryCode) -> InMemoryCatalogProvider {
        InMemoryCatalogProvider(
            series: series(now: now),
            movies: movies,
            popular: [country: items(now: now)]
        )
    }

    // MARK: Series

    private struct SeriesSpec {
        let id: Int
        let title: String
        let year: Int
        let status: AiringStatus
        let genres: [Genre]
        let runtime: Int
        /// Episodes per season.
        let seasons: [Int]
        /// Episodes already aired, counting from the first; the rest air weekly from tomorrow.
        let aired: Int
    }

    private static let seriesSpecs: [SeriesSpec] = [
        SeriesSpec(
            id: 9001,
            title: "La casa del faro",
            year: 2025,
            status: .airing,
            genres: [Genre.drama, .mystery],
            runtime: 52,
            seasons: [8, 8],
            aired: 12
        ),
        SeriesSpec(
            id: 9002,
            title: "Órbita baja",
            year: 2021,
            status: .ended,
            genres: [Genre.sciFiFantasy],
            runtime: 45,
            seasons: [6, 6, 6],
            aired: 18
        ),
        SeriesSpec(
            id: 9003,
            title: "Turno de noche",
            year: 2024,
            status: .airing,
            genres: [Genre.comedy],
            runtime: 28,
            seasons: [10, 8],
            aired: 12
        ),
        SeriesSpec(
            id: 9004,
            title: "Los archivos de Marta Vidal",
            year: 2023,
            status: .canceled,
            genres: [Genre.crime, .mystery],
            runtime: 50,
            seasons: [8],
            aired: 8
        ),
        SeriesSpec(
            id: 9005,
            title: "Pan y mantequilla",
            year: 2019,
            status: .ended,
            genres: [Genre.comedy, .family],
            runtime: 24,
            seasons: [10, 10],
            aired: 20
        ),
        SeriesSpec(
            id: 9006,
            title: "Cordillera",
            year: 2026,
            status: .airing,
            genres: [Genre.drama, .actionAdventure],
            runtime: 58,
            seasons: [6],
            aired: 3
        ),
        SeriesSpec(
            id: 9007,
            title: "Mareas",
            year: 2022,
            status: .ended,
            genres: [Genre.drama],
            runtime: 61,
            seasons: [5],
            aired: 5
        ),
        SeriesSpec(
            id: 9008,
            title: "Ciudad dormida",
            year: 2016,
            status: .ended,
            genres: [Genre.crime, .drama],
            runtime: 42,
            seasons: [8, 8, 8, 8],
            aired: 32
        ),
    ]

    private static func series(now: Date) -> [SeriesDetails] {
        seriesSpecs.map { details(of: $0, now: now) }
    }

    private static func details(of spec: SeriesSpec, now: Date) -> SeriesDetails {
        let id = SeriesID(spec.id)
        let references = spec.seasons.enumerated().flatMap { index, count in
            (1...count).map { EpisodeReference(seriesID: id, seasonNumber: index + 1, episodeNumber: $0) }
        }
        let episodes = references.enumerated().map { position, reference in
            Episode(
                id: reference,
                title: episodeTitles[(position + spec.id) % episodeTitles.count],
                runtimeMinutes: spec.runtime + (position % 3) - 1,
                airDate: airDate(position: position, aired: spec.aired, now: now)
            )
        }
        let series = Series(
            id: id,
            title: spec.title,
            year: spec.year,
            seasonCount: spec.seasons.count,
            airingStatus: spec.status,
            genres: spec.genres,
            keywords: [],
            posterURL: nil
        )
        let seasons = spec.seasons.enumerated().map {
            Season(seriesID: id, number: $0.offset + 1, episodeCount: $0.element)
        }
        return SeriesDetails(series: series, seasons: seasons, episodes: episodes, availability: [])
    }

    /// Aired episodes are a week apart, the last one three days ago; the next ones air weekly.
    private static func airDate(position: Int, aired: Int, now: Date) -> Date {
        let day: TimeInterval = 86_400
        let weeksFromLastAired = Double(position - aired + 1)
        return now.addingTimeInterval(weeksFromLastAired * 7 * day - 3 * day)
    }

    private static let episodeTitles = [
        "El regreso", "Marea alta", "Lo que no se dijo", "La llave", "Cartas sin abrir", "El faro apagado",
        "Fuera de plano", "Noche cerrada", "La otra orilla", "Último aviso", "Ruido blanco", "Puertas adentro",
        "El mapa", "Hora punta", "Media vuelta", "Deshielo", "La señal", "Sin cobertura", "Domingo",
        "El inventario", "Viento sur", "Doble fondo", "La mudanza", "Punto ciego",
    ]

    // MARK: Movies

    private static let movies: [MovieDetails] = [
        movie(9101, "El último tranvía", 2024, 112, [.drama]),
        movie(9102, "Nebulosa once", 2025, 138, [.scienceFiction, .adventure]),
        movie(9103, "Domingo de lluvia", 2023, 96, [.comedy, .romance]),
        movie(9104, "Taller de relojes", 2022, 104, [.drama, .mystery]),
        movie(9105, "Cometas en agosto", 2026, 89, [.family, .animation]),
        movie(9106, "Doce tejados", 2021, 121, [.thriller, .crime]),
    ]

    private static func movie(_ id: Int, _ title: String, _ year: Int, _ runtime: Int, _ genres: [Genre])
        -> MovieDetails
    {
        let movie = Movie(
            id: MovieID(id),
            title: title,
            year: year,
            runtimeMinutes: runtime,
            genres: genres,
            keywords: [],
            posterURL: nil
        )
        return MovieDetails(movie: movie, availability: [])
    }
}

// TMDB genre IDs used by the samples.
extension Genre {
    fileprivate static let drama = Genre(id: 18, name: "Drama")
    fileprivate static let comedy = Genre(id: 35, name: "Comedy")
    fileprivate static let crime = Genre(id: 80, name: "Crime")
    fileprivate static let mystery = Genre(id: 9648, name: "Mystery")
    fileprivate static let family = Genre(id: 10751, name: "Family")
    fileprivate static let animation = Genre(id: 16, name: "Animation")
    fileprivate static let romance = Genre(id: 10749, name: "Romance")
    fileprivate static let thriller = Genre(id: 53, name: "Thriller")
    fileprivate static let adventure = Genre(id: 12, name: "Adventure")
    fileprivate static let scienceFiction = Genre(id: 878, name: "Science Fiction")
    fileprivate static let sciFiFantasy = Genre(id: 10765, name: "Sci-Fi & Fantasy")
    fileprivate static let actionAdventure = Genre(id: 10759, name: "Action & Adventure")
}
