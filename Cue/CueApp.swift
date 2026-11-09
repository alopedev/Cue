import CueKit
import DesignSystem
import SwiftUI

@main
struct CueApp: App {
    @State private var library: AppDependencies.Library

    init() {
        // Titles fall back to the system font if this fails, so the app keeps working.
        try? CueFonts.register()
        _library = State(initialValue: AppDependencies.makeLibrary())
    }

    var body: some Scene {
        WindowGroup {
            RootView(library: library.model, isSavedOnDevice: library.isSavedOnDevice)
        }
    }
}
