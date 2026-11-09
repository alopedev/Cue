import CueKit
import DesignSystem
import SwiftUI

/// The library: a grid of posters grouped by shelf, with the catch-up time on top (RF-34, RF-37).
struct LibraryScreen: View {
    let library: LibraryModel

    @State private var selectedShelf: LibraryShelf = .watching
    @State private var hasChosenShelf = false
    @State private var showsAddTitles = false
    @State private var openTitle: OpenTitle?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CueSpacing.space6) {
                header
                if library.isLoaded && library.entries.isEmpty {
                    LibraryEmptyState { showsAddTitles = true }
                } else if library.isLoaded {
                    if library.catchUpMinutes > 0 {
                        CatchUpCard(minutes: library.catchUpMinutes, seriesCount: watchingSeriesCount)
                    }
                    ShelfBar(shelves: visibleShelves, selected: $selectedShelf, count: count(on:))
                    shelfContent
                }
            }
            .padding(.horizontal, CueSpacing.space4)
            .padding(.top, CueSpacing.space2)
            .padding(.bottom, CueSpacing.space12 * 2)
        }
        .scrollIndicators(.hidden)
        .background(CueColor.canvas)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showsAddTitles) {
            AddTitlesSheet(library: library)
        }
        .sheet(item: $openTitle) { title in
            TitleDetailSheet(library: library, titleID: title.id)
        }
        .overlay(alignment: .bottom) {
            UndoToast(library: library)
        }
        .overlay {
            if openTitle == nil && !showsAddTitles {
                CelebrationOverlay(library: library)
            }
        }
        .markingFeedback(library)
        .onChange(of: library.entries) { chooseInitialShelf() }
    }

    private var header: some View {
        HStack(alignment: .center) {
            Text("Biblioteca")
                .cueTextStyle(.title)
                .foregroundStyle(CueColor.ink)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("library.title")
            Spacer()
            if !library.entries.isEmpty {
                RoundIconButton(systemName: "plus", label: "Añadir títulos") { showsAddTitles = true }
                    .accessibilityIdentifier("library.add")
            }
        }
        .padding(.top, CueSpacing.space4)
    }

    @ViewBuilder
    private var shelfContent: some View {
        let entries = library.entries(on: selectedShelf)
        if entries.isEmpty {
            ShelfEmptyMessage(shelf: selectedShelf)
        } else {
            LibraryGrid(entries: entries, library: library) { openTitle = OpenTitle(id: $0) }
        }
    }

    private var watchingSeriesCount: Int {
        library.entries(on: .watching).count
    }

    private func count(on shelf: LibraryShelf) -> Int {
        library.entries(on: shelf).count
    }

    /// Viendo always shows; the other shelves only when they have titles or are selected.
    private var visibleShelves: [LibraryShelf] {
        LibraryShelf.allCases.filter { $0 == .watching || $0 == selectedShelf || count(on: $0) > 0 }
    }

    /// Opens on Viendo; if it is empty, on the first shelf with titles. Only once.
    private func chooseInitialShelf() {
        guard !hasChosenShelf, !library.entries.isEmpty else { return }
        hasChosenShelf = true
        if count(on: .watching) == 0, let first = LibraryShelf.allCases.first(where: { count(on: $0) > 0 }) {
            selectedShelf = first
        }
    }
}

/// The title whose detail sheet is open.
struct OpenTitle: Identifiable, Hashable {
    let id: TitleID
}

/// A 44-point round button with an icon, for secondary actions in headers.
struct RoundIconButton: View {
    let systemName: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(CueColor.ink)
                .frame(width: 44, height: 44)
                .background(Circle().fill(CueColor.surfaceSunken))
                .background(alignment: .bottom) {
                    Circle().fill(CueColor.softEdge).offset(y: CueDepth.soft)
                }
                .padding(.bottom, CueDepth.soft)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}
