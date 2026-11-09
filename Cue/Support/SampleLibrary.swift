#if DEBUG
    import CueKit
    import Foundation

    /// Fills an empty library with sample titles in every state, for screenshots.
    enum SampleLibrary {
        @MainActor
        static func fill(_ library: LibraryModel) async {
            let items = SampleCatalog.items(now: Date())
            for item in items { await library.add(item) }
            for entry in library.entries {
                switch entry {
                case .series(let series):
                    await mark(series, in: library)
                case .movie(let movie) where movie.details.movie.title.hasPrefix("El último"):
                    await library.markWatched(movie.id)
                case .movie:
                    break
                }
            }
            library.dismissCelebration()
        }

        @MainActor
        private static func mark(_ series: SeriesEntry, in library: LibraryModel) async {
            let aired = series.progress.episodes.prefix(series.progress.airedCount)
            let watchedCount: Int =
                switch series.details.series.title {
                case "La casa del faro": 9
                case "Turno de noche": aired.count
                case "Ciudad dormida": 11
                case "Mareas": aired.count
                case "Cordillera": 1
                default: 0
                }
            guard watchedCount > 0, let last = aired.prefix(watchedCount).last else { return }
            await library.markThrough(last.id)
        }
    }
#endif
