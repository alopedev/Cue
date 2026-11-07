import SwiftUI

/// Cue's own capsule button with a solid edge that sinks when pressed (RNF-11).
///
/// Use it only for Cue's own actions; lists, settings and sheets keep Apple's standard buttons.
public struct CueButtonStyle: ButtonStyle {
    public enum Prominence: Sendable {
        /// The action of the screen. One per screen.
        case primary
        /// The alternative.
        case secondary
    }

    let prominence: Prominence
    let fillsWidth: Bool

    public init(_ prominence: Prominence = .primary, fillsWidth: Bool = false) {
        self.prominence = prominence
        self.fillsWidth = fillsWidth
    }

    public func makeBody(configuration: Configuration) -> some View {
        CueButtonBody(configuration: configuration, prominence: prominence, fillsWidth: fillsWidth)
    }
}

extension ButtonStyle where Self == CueButtonStyle {
    public static var cuePrimary: CueButtonStyle { CueButtonStyle(.primary) }
    public static var cueSecondary: CueButtonStyle { CueButtonStyle(.secondary) }
}

private struct CueButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let prominence: CueButtonStyle.Prominence
    let fillsWidth: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    /// Taller than Apple's 44 pt minimum touch target.
    static let minimumHeight: CGFloat = 52

    var body: some View {
        let motion = PressMotion(
            depth: isEnabled ? CueDepth.button : 0,
            isPressed: configuration.isPressed,
            reduceMotion: reduceMotion
        )
        configuration.label
            .cueTextStyle(.label)
            .foregroundStyle(colors.text)
            .multilineTextAlignment(.center)
            .padding(.horizontal, CueSpacing.space6)
            .padding(.vertical, CueSpacing.space3)
            .frame(maxWidth: fillsWidth ? .infinity : nil, minHeight: Self.minimumHeight)
            .background(Capsule().fill(colors.fill))
            .contentShape(Capsule())
            .offset(y: motion.offset)
            .background(alignment: .bottom) {
                Capsule().fill(colors.edge).offset(y: CueDepth.button).opacity(motion.edgeHeight > 0 ? 1 : 0)
            }
            .padding(.bottom, CueDepth.button)
            .opacity(isEnabled ? motion.opacity : 0.45)
            .animation(motion.animation, value: configuration.isPressed)
    }

    private var colors: PieceColors {
        switch prominence {
        case .primary: PieceColors(fill: CueColor.cue, text: CueColor.onCue, edge: CueColor.cueEdge)
        case .secondary: PieceColors(fill: CueColor.surfaceSunken, text: CueColor.ink, edge: CueColor.softEdge)
        }
    }
}
