import SwiftUI

/// Placeholder root screen. Real screens arrive with the first block.
struct RootView: View {
    var body: some View {
        Text("Cue")
            .font(.largeTitle)
            .accessibilityIdentifier("root.title")
    }
}

#Preview {
    RootView()
}
