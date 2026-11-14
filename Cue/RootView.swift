import CueKit
import DesignSystem
import SwiftUI

/// The app's first screen. «Esta noche» joins the library in block 3.
struct RootView: View {
    let library: LibraryModel
    let isSavedOnDevice: Bool

    #if DEBUG
        /// Launch with `-designCatalog` to open the design catalog directly (screenshots).
        @State private var showsDesignCatalog = ProcessInfo.processInfo.arguments.contains("-designCatalog")
        /// True once the sample titles and their marks are all in (see `-sampleLibrary`).
        @State private var sampleLibraryIsReady = false
    #endif

    var body: some View {
        NavigationStack {
            libraryScreen
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
                sampleLibraryIsReady = true
            #endif
        }
    }

    private var libraryScreen: LibraryScreen {
        #if DEBUG
            LibraryScreen(library: library, isSavedOnDevice: isSavedOnDevice, opensLaunchTitle: sampleLibraryIsReady)
        #else
            LibraryScreen(library: library, isSavedOnDevice: isSavedOnDevice)
        #endif
    }
}
