import CueKit
import Foundation

/// Builds the real pieces the app runs on. Launch arguments switch them for tests and screenshots.
enum AppDependencies {
    /// Fresh, empty library kept only in memory (UI tests).
    static let freshLibraryArgument = "-freshLibrary"
    /// Fresh library filled with sample titles in every state (screenshots). Debug builds only.
    static let sampleLibraryArgument = "-sampleLibrary"

    static var arguments: [String] { ProcessInfo.processInfo.arguments }

    /// The iPhone's region, without asking (RF-51). Spain if the region is unknown.
    static var country: CountryCode {
        CountryCode(Locale.current.region?.identifier ?? "ES")
    }

    @MainActor
    static func makeLibrary() -> LibraryModel {
        let clock = SystemClock()
        return LibraryModel(
            store: makeStore(),
            catalog: SampleCatalog.provider(now: clock.now, country: country),
            clock: clock,
            country: country
        )
    }

    private static func makeStore() -> any LibraryStore {
        if arguments.contains(freshLibraryArgument) || arguments.contains(sampleLibraryArgument) {
            return InMemoryLibraryStore()
        }
        // Saved on the iPhone (iCloud comes in block 4). If the file cannot be opened,
        // the app still works for this session instead of crashing.
        return (try? SwiftDataLibraryStore()) ?? InMemoryLibraryStore()
    }
}
