import CueKit
import DesignSystem
import SwiftUI

/// The only big celebration: finishing a season, a series or a movie (RNF-02).
struct CelebrationOverlay: View {
    let library: LibraryModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        ZStack {
            if let celebration = library.celebration {
                CueColor.canvas.opacity(0.94)
                    .ignoresSafeArea()
                    .onTapGesture { library.dismissCelebration() }
                    .transition(.opacity)
                content(for: celebration)
                    .transition(reduceMotion ? .opacity : .scale(scale: 0.85).combined(with: .opacity))
            }
        }
        .animation(
            reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.45, dampingFraction: 0.7),
            value: library.celebration
        )
        .sensoryFeedback(.success, trigger: library.celebration) { _, new in new != nil }
    }

    private func content(for celebration: Celebration) -> some View {
        VStack(spacing: CueSpacing.space4) {
            MascotStage(Image("mascot-celebration"))
                .rotationEffect(.degrees(appeared || reduceMotion ? 0 : -8))
                .scaleEffect(appeared || reduceMotion ? 1 : 0.9)
                .onAppear {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.45).delay(0.1)) {
                        appeared = true
                    }
                }
                .onDisappear { appeared = false }
            Text(headline(for: celebration))
                .cueTextStyle(.ticketTitle)
                .foregroundStyle(CueColor.ink)
                .multilineTextAlignment(.center)
            Text(celebration.title)
                .cueTextStyle(.body)
                .foregroundStyle(CueColor.inkMuted)
                .multilineTextAlignment(.center)
            Button("Seguir") { library.dismissCelebration() }
                .buttonStyle(.cuePrimary)
                .padding(.top, CueSpacing.space2)
                .accessibilityIdentifier("celebration.continue")
        }
        .padding(CueSpacing.space8)
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }

    private func headline(for celebration: Celebration) -> String {
        switch celebration.kind {
        case .seasonFinished(let number): "Temporada \(number) terminada"
        case .seriesFinished: "Serie terminada"
        case .movieWatched: "Película vista"
        }
    }
}

extension View {
    /// A light tap when the user marks something as watched (RNF-05). Celebrations add their own.
    func markingFeedback(_ library: LibraryModel) -> some View {
        sensoryFeedback(trigger: library.pendingUndo) { _, new in
            new == nil ? nil : .impact(weight: .medium)
        }
    }
}
