import CueKit
import DesignSystem
import SwiftUI

/// A movie's sheet: its runtime and the one-tap button to mark it watched (RF-30).
struct MovieDetailView: View {
    let movie: MovieEntry
    let library: LibraryModel

    var body: some View {
        List {
            Section {
                DetailHeader(
                    title: details.movie.title,
                    facts: facts,
                    status: LibraryText.movieStatus(movie.tracking.status)
                )
            }
            Section {
                VStack(alignment: .leading, spacing: CueSpacing.space3) {
                    if let minutes = details.movie.runtimeMinutes {
                        DetailStat(label: "Duración", value: DurationText.string(minutes: minutes))
                    }
                    if movie.tracking.status == .watched {
                        Label(watchedText, systemImage: "checkmark.circle.fill")
                            .cueTextStyle(.label)
                            .foregroundStyle(CueColor.success)
                    } else {
                        Button("Marcar vista") {
                            Task { await library.markWatched(movie.id) }
                        }
                        .buttonStyle(.cuePrimary)
                        .accessibilityIdentifier("detail.markMovie")
                    }
                }
                .padding(.vertical, CueSpacing.space2)
                .listRowBackground(CueColor.surface)
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(CueSpacing.space4)
    }

    private var details: MovieDetails { movie.details }

    private var facts: [String] {
        ["Película", details.movie.year.map(String.init)].compactMap { $0 }
    }

    private var watchedText: String {
        movie.tracking.watchedAt.map { "Vista el \(LibraryText.shortDate($0))" } ?? "Vista"
    }
}
