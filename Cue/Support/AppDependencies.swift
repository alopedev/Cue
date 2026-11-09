import CueKit
import Foundation

/// Builds the real pieces the app runs on. Launch arguments switch them for tests and screenshots.
enum AppDependencies {
    /// Fresh, empty library kept only in memory (UI tests).
    static let freshLibraryArgument = "-freshLibrary"
    /// Fresh library filled with sample titles in every state (screenshots). Debug builds only.
    static let sampleLibraryArgument = "-sampleLibrary"

    /// With one of the two above: shows the «not saved» notice (screenshots).
    static let storageProblemArgument = "-storageProblem"

    static var arguments: [String] { ProcessInfo.processInfo.arguments }

    /// The iPhone's region, without asking (RF-51). Spain if the region is unknown.
    static var country: CountryCode {
        CountryCode(Locale.current.region?.identifier ?? "ES")
    }

    /// The library and whether it is saved on the iPhone.
    struct Library {
        let model: LibraryModel
        /// False when the saved library could not be opened: changes last only until the app closes.
        let isSavedOnDevice: Bool
    }

    @MainActor
    static func makeLibrary() -> Library {
        let clock = SystemClock()
        let storage = makeStore()
        let model = LibraryModel(
            store: storage.store,
            catalog: SampleCatalog.provider(now: clock.now, country: country),
            clock: clock,
            country: country
        )
        return Library(model: model, isSavedOnDevice: storage.isSavedOnDevice)
    }

    private static func makeStore() -> (store: any LibraryStore, isSavedOnDevice: Bool) {
        if arguments.contains(freshLibraryArgument) || arguments.contains(sampleLibraryArgument) {
            return (InMemoryLibraryStore(), !arguments.contains(storageProblemArgument))
        }
        // Saved on the iPhone (iCloud comes in block 4). If the file cannot be opened, the app
        // still works for this session instead of crashing, and the library screen says so.
        guard let store = try? SwiftDataLibraryStore() else { return (InMemoryLibraryStore(), false) }
        return (store, true)
    }
}
