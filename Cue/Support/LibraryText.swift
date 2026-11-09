import CueKit
import Foundation

/// The Spanish words the library shows for shelves, statuses, episodes and dates.
enum LibraryText {
    static func shelfName(_ shelf: LibraryShelf) -> String {
        switch shelf {
        case .watching: "Viendo"
        case .pending: "Pendientes"
        case .upToDate: "Al día"
        case .paused: "Pausadas"
        case .finished: "Vistas"
        case .dropped: "Dejadas"
        }
    }

    /// «T2 · E5»
    static func episodeCode(_ episode: EpisodeReference) -> String {
        "T\(episode.seasonNumber) · E\(episode.episodeNumber)"
    }

    /// «temporada 2, episodio 5», for VoiceOver.
    static func spokenEpisode(_ episode: EpisodeReference) -> String {
        "temporada \(episode.seasonNumber), episodio \(episode.episodeNumber)"
    }

    static func seriesStatus(_ status: SeriesStatus) -> String {
        switch status {
        case .pending: "Pendiente"
        case .watching: "Viendo"
        case .upToDate: "Al día"
        case .paused: "Pausada"
        case .abandoned: "Abandonada"
        case .finished: "Terminada"
        }
    }

    static func movieStatus(_ status: MovieStatus) -> String {
        switch status {
        case .pending: "Pendiente"
        case .watched: "Vista"
        case .dismissed: "Descartada"
        }
    }

    static func airingStatus(_ status: AiringStatus) -> String {
        switch status {
        case .airing: "En emisión"
        case .ended: "Finalizada"
        case .canceled: "Cancelada"
        }
    }

    /// The line under a poster in the grid.
    static func tileState(_ entry: LibraryEntry) -> String {
        switch entry {
        case .series(let series):
            if series.tracking.status == .watching, let next = series.progress.currentEpisode {
                return "Viendo · \(episodeCode(next.id))"
            }
            return seriesStatus(series.tracking.status)
        case .movie(let movie):
            return "Película · \(movieStatus(movie.tracking.status))"
        }
    }

    /// «12 nov.»
    static func shortDate(_ date: Date) -> String {
        date.formatted(.dateTime.day().month(.abbreviated).locale(spanish))
    }

    static func seasons(_ count: Int) -> String {
        count == 1 ? "1 temporada" : "\(count) temporadas"
    }

    static func episodes(_ count: Int) -> String {
        count == 1 ? "1 episodio" : "\(count) episodios"
    }

    private static let spanish = Locale(identifier: "es_ES")
}
