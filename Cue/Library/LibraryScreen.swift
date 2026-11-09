import CueKit
import DesignSystem
import SwiftUI

/// The library: a grid of posters grouped by shelf, with the catch-up time on top (RF-34, RF-37).
struct LibraryScreen: View {
    let library: LibraryModel
    let isSavedOnDevice: Bool

    /// The shelf the user tapped. Until then the screen picks one (see `automaticShelf`).
    @State private var chosenShelf: LibraryShelf?
    @State private var showsAddTitles = false
    @State private var openTitle: OpenTitle?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CueSpacing.space6) {
                header
                if let problem { ProblemNotice(problem: problem) }
                if library.isLoaded && library.entries.isEmpty {
                    LibraryEmptyState { showsAddTitles = true }
                } else if library.isLoaded {
                    if library.catchUpMinutes > 0 {
                        CatchUpCard(minutes: library.catchUpMinutes, seriesCount: watchingSeriesCount)
                    }
                    ShelfBar(shelves: visibleShelves, selected: selectedShelfBinding, count: count(on:))
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
        // While a sheet is open, the sheet shows these itself, so they never appear twice.
        .safeAreaInset(edge: .bottom) {
            // An inset, not an overlay: the grid can scroll above it instead of hiding under it.
            if !isShowingSheet { UndoToast(library: library) }
        }
        .overlay {
            if !isShowingSheet { CelebrationOverlay(library: library) }
        }
        .markingFeedback(library)
        #if DEBUG
            .onChange(of: library.entries.count) { openTitleFromLaunchArguments() }
        #endif
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

    /// The most serious thing that went wrong with the user's data, if any.
    private var problem: ProblemNotice.Problem? {
        if !isSavedOnDevice { return .notSavedOnDevice }
        if library.hasSavingProblem { return .lastChangeNotSaved }
        if library.hasLoadingProblem { return .someTitlesMissing }
        return nil
    }

    private var isShowingSheet: Bool { openTitle != nil || showsAddTitles }

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

    #if DEBUG
        /// Launch with `-openTitle "<name>"` to open that title's sheet (screenshots).
        private func openTitleFromLaunchArguments() {
            let arguments = AppDependencies.arguments
            guard openTitle == nil, let flag = arguments.firstIndex(of: "-openTitle"), flag + 1 < arguments.count,
                let entry = library.entries.first(where: { $0.title == arguments[flag + 1] })
            else { return }
            openTitle = OpenTitle(id: entry.id)
        }
    #endif

    private var selectedShelf: LibraryShelf { chosenShelf ?? automaticShelf }

    private var selectedShelfBinding: Binding<LibraryShelf> {
        Binding(get: { selectedShelf }, set: { chosenShelf = $0 })
    }

    /// Viendo by default (RF-34); while it is empty, the first shelf that has titles.
    private var automaticShelf: LibraryShelf {
        guard count(on: .watching) == 0 else { return .watching }
        return LibraryShelf.allCases.first { count(on: $0) > 0 } ?? .watching
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
