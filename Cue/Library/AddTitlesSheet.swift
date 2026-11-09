import CueKit
import DesignSystem
import SwiftUI

/// Pick series and movies to add, one tap each (RF-49). The real search arrives with TMDB.
struct AddTitlesSheet: View {
    let library: LibraryModel

    @Environment(\.dismiss) private var dismiss
    @State private var items: [CatalogItem] = []

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: CueSpacing.space3, alignment: .top),
        count: 3
    )

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: CueSpacing.space6) {
                    Text("Toca lo que estés viendo o quieras ver.")
                        .cueTextStyle(.body)
                        .foregroundStyle(CueColor.inkMuted)
                    section("Series", items: items.filter(\.isSeries))
                    section("Películas", items: items.filter { !$0.isSeries })
                }
                .padding(.horizontal, CueSpacing.space4)
                .padding(.bottom, CueSpacing.space8)
            }
            .background(CueColor.canvas)
            .navigationTitle("Añadir títulos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                        .accessibilityIdentifier("add.done")
                }
            }
        }
        .task { items = SampleCatalog.items(now: Date()) }
    }

    private func section(_ title: String, items: [CatalogItem]) -> some View {
        VStack(alignment: .leading, spacing: CueSpacing.space3) {
            Text(title)
                .cueTextStyle(.label)
                .foregroundStyle(CueColor.ink)
                .accessibilityAddTraits(.isHeader)
            LazyVGrid(columns: columns, alignment: .leading, spacing: CueSpacing.space4) {
                ForEach(items, id: \.titleID) { item in
                    AddableTile(item: item, isAdded: library.contains(item)) {
                        Task { await library.add(item) }
                    }
                }
            }
        }
    }
}

/// A catalog poster that adds the title on tap and then shows a coral check.
private struct AddableTile: View {
    let item: CatalogItem
    let isAdded: Bool
    let add: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: add) {
            VStack(alignment: .leading, spacing: CueSpacing.space1) {
                CuePoster(title: item.title)
                    .overlay(alignment: .topTrailing) {
                        if isAdded {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .heavy))
                                .foregroundStyle(CueColor.onCue)
                                .frame(width: 28, height: 28)
                                .background(Circle().fill(CueColor.cue))
                                .padding(CueSpacing.space2)
                                .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
                        }
                    }
                    .offset(y: isAdded && !reduceMotion ? -2 : 0)
                Text(item.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(CueColor.ink)
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)
                    .padding(.top, CueSpacing.space1)
                Text(item.subtitle)
                    .cueTextStyle(.caption)
                    .foregroundStyle(CueColor.inkMuted)
                    .lineLimit(1)
            }
        }
        .buttonStyle(TileButtonStyle())
        .disabled(isAdded)
        .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.6), value: isAdded)
        .sensoryFeedback(.selection, trigger: isAdded)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(item.title), \(item.subtitle)")
        .accessibilityValue(isAdded ? "Añadida" : "")
        .accessibilityAddTraits(isAdded ? [.isButton, .isSelected] : .isButton)
        .accessibilityIdentifier("add.\(item.title)")
    }
}

extension CatalogItem {
    var title: String {
        switch self {
        case .series(let series): series.title
        case .movie(let movie): movie.title
        }
    }

    var isSeries: Bool {
        if case .series = self { true } else { false }
    }

    /// «Serie · 2021» or «Película · 1 h 52 min».
    var subtitle: String {
        switch self {
        case .series(let series):
            series.year.map { "Serie · \($0)" } ?? "Serie"
        case .movie(let movie):
            movie.runtimeMinutes.map { "Película · \(DurationText.string(minutes: $0))" } ?? "Película"
        }
    }
}
