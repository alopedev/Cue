import DesignSystem
import SwiftUI

/// The first thing a new user sees: the character, one sentence and a way to start.
struct LibraryEmptyState: View {
    let addTitles: () -> Void

    var body: some View {
        VStack(spacing: CueSpacing.space4) {
            MascotStage(Image("mascot-empty-library"))
                .padding(.bottom, CueSpacing.space2)
            Text("Tu biblioteca está vacía")
                .cueTextStyle(.ticketTitle)
                .foregroundStyle(CueColor.ink)
                .multilineTextAlignment(.center)
            Text("Añade las series y películas que estás viendo o quieres ver.")
                .cueTextStyle(.body)
                .foregroundStyle(CueColor.inkMuted)
                .multilineTextAlignment(.center)
            Button("Añadir títulos", action: addTitles)
                .buttonStyle(CueButtonStyle(.primary, size: .large))
                .padding(.top, CueSpacing.space4)
                .accessibilityIdentifier("library.emptyAdd")
        }
        .frame(maxWidth: .infinity)
        .padding(.top, CueSpacing.space12)
        .padding(.horizontal, CueSpacing.space4)
    }
}
