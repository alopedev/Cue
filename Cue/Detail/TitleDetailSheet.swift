import CueKit
import DesignSystem
import SwiftUI

/// The detail sheet of a series or movie (design system: fichas use Apple's standard sheet).
struct TitleDetailSheet: View {
    let library: LibraryModel
    let titleID: TitleID

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                switch entry {
                case .series(let series): SeriesDetailView(series: series, library: library)
                case .movie(let movie): MovieDetailView(movie: movie, library: library)
                case nil: ContentUnavailableView("Este título ya no está en tu biblioteca", systemImage: "film")
                }
            }
            .scrollContentBackground(.hidden)
            .background(CueColor.canvas)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Cerrar") { dismiss() }
                        .accessibilityIdentifier("detail.close")
                }
            }
        }
        .overlay(alignment: .bottom) { UndoToast(library: library) }
        .overlay { CelebrationOverlay(library: library) }
        .markingFeedback(library)
    }

    private var entry: LibraryEntry? {
        library.entries.first { $0.id == titleID }
    }
}

/// Poster, name and the facts of a title, at the top of its sheet.
struct DetailHeader: View {
    let title: String
    let facts: [String]
    let status: String

    var body: some View {
        HStack(alignment: .top, spacing: CueSpacing.space4) {
            CuePoster(title: title)
                .frame(width: 104)
            VStack(alignment: .leading, spacing: CueSpacing.space2) {
                Text(title)
                    .cueTextStyle(.ticketTitle)
                    .foregroundStyle(CueColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                Text(facts.joined(separator: " · "))
                    .cueTextStyle(.callout)
                    .foregroundStyle(CueColor.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
                StatusPill(text: status)
                    .padding(.top, CueSpacing.space1)
            }
            Spacer(minLength: 0)
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .padding(.vertical, CueSpacing.space2)
    }
}

/// The title's status, as a small capsule with its word.
struct StatusPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(CueColor.ink)
            .padding(.horizontal, CueSpacing.space3)
            .frame(minHeight: 26)
            .background(Capsule().fill(CueColor.surfaceSunken))
            .accessibilityLabel("Estado: \(text)")
    }
}

/// A large number with its label, such as the remaining time.
struct DetailStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: CueSpacing.space1) {
            Text(label)
                .cueTextStyle(.caption)
                .foregroundStyle(CueColor.inkMuted)
            Text(value)
                .font(.system(.title2, design: .monospaced, weight: .semibold))
                .foregroundStyle(CueColor.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
