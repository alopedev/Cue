import CueKit
import DesignSystem
import SwiftUI

/// The app's first screen. «Esta noche» joins the library in block 3.
struct RootView: View {
    let library: LibraryModel

    #if DEBUG
        /// Launch with `-designCatalog` to open the design catalog directly (screenshots).
        @State private var showsDesignCatalog = ProcessInfo.processInfo.arguments.contains("-designCatalog")
    #endif

    var body: some View {
        NavigationStack {
            LibraryScreen(library: library)
                #if DEBUG
                    .navigationDestination(isPresented: $showsDesignCatalog) {
                        DesignSystemCatalog()
                        .navigationTitle("Sistema de diseño")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                #endif
        }
        .tint(CueColor.cue)
        .task {
            guard !library.isLoaded else { return }
            await library.load()
            #if DEBUG
                if AppDependencies.arguments.contains(AppDependencies.sampleLibraryArgument) {
                    await SampleLibrary.fill(library)
                }
            #endif
        }
    }
}
