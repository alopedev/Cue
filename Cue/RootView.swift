import DesignSystem
import SwiftUI

/// Placeholder root screen. Real screens arrive with the first block.
struct RootView: View {
    #if DEBUG
        /// Launch with `-designCatalog` to open the catalog directly (screenshots).
        @State private var showsDesignCatalog = ProcessInfo.processInfo.arguments.contains("-designCatalog")
    #endif

    var body: some View {
        NavigationStack {
            VStack(spacing: CueSpacing.lg) {
                Text("Cue")
                    .cueTextStyle(.display)
                    .accessibilityIdentifier("root.title")
                #if DEBUG
                    Button("Ver sistema de diseño") { showsDesignCatalog = true }
                        .buttonStyle(.cueSecondary)
                        .accessibilityIdentifier("root.designCatalog")
                #endif
            }
            .foregroundStyle(CueColor.ink)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(CueColor.canvas)
            #if DEBUG
                .navigationDestination(isPresented: $showsDesignCatalog) {
                    DesignSystemCatalog()
                    .navigationTitle("Sistema de diseño")
                    .navigationBarTitleDisplayMode(.inline)
                }
            #endif
        }
    }
}

#Preview {
    RootView()
}
