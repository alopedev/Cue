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
            // An inset, not an overlay: the undo capsule never covers the buttons above it.
            .safeAreaInset(edge: .bottom) { UndoToast(library: library) }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Cerrar") { dismiss() }
                        .accessibilityIdentifier("detail.close")
                }
            }
        }
        .presentationDetents(entry?.movieEntry == nil ? [.large] : [.fraction(0.62), .large])
        .presentationDragIndicator(.visible)
        .overlay { CelebrationOverlay(library: library) }
        .markingFeedback(library)
    }

    private var entry: LibraryEntry? {
        library.entries.first { $0.id == titleID }
    }
}

/// Poster, name, the facts of a title and the user's status, at the top of its sheet.
struct DetailHeader: View {
    let title: String
    /// Short facts such as «2024», «2 temporadas» or «En emisión». Each one says something new.
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
                DetailFacts(facts: facts)
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

/// The facts of a title on one line, «2024 · 2 temporadas · En emisión». When they do not fit
/// (large text), one per line: a line never ends in a loose «·» nor splits a fact in two.
struct DetailFacts: View {
    let facts: [String]

    var body: some View {
        ViewThatFits(in: .horizontal) {
            factText(facts.joined(separator: " · "))
                .lineLimit(1)
            VStack(alignment: .leading, spacing: 2) {
                ForEach(facts, id: \.self) { fact in
                    factText(fact).fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(facts.joined(separator: ", "))
    }

    private func factText(_ text: String) -> some View {
        Text(text)
            .cueTextStyle(.callout)
            .foregroundStyle(CueColor.inkMuted)
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

/// A large number with its label, such as the remaining time. It rolls when the number changes.
struct DetailStat: View {
    let label: String
    let value: String
    /// The number behind `value` (minutes, episodes), so the roll goes up or down with it.
    let number: Int

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
                .cueRollingNumber(Double(number))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
