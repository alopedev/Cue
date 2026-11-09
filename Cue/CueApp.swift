import DesignSystem
import SwiftUI

@main
struct CueApp: App {
    init() {
        // Titles fall back to the system font if this fails, so the app keeps working.
        try? CueFonts.register()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
