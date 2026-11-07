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

    /// Buttons have fixed sizes; they never stretch to fill the space around them.
    public enum Size: Sendable {
        /// The main action of a screen, such as «Recomiéndame». 52 × 240 pt minimum.
        case large
        /// Every other Cue action. 44 × 140 pt minimum (Apple's touch target).
        case regular

        var minimumHeight: CGFloat {
            switch self {
            case .large: 52
            case .regular: 44
            }
        }

        var minimumWidth: CGFloat {
            switch self {
            case .large: 240
            case .regular: 140
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .large: CueSpacing.space8
            case .regular: CueSpacing.space6
            }
        }
    }

    let prominence: Prominence
    let size: Size

    public init(_ prominence: Prominence = .primary, size: Size = .regular) {
        self.prominence = prominence
        self.size = size
    }

    public func makeBody(configuration: Configuration) -> some View {
        CueButtonBody(configuration: configuration, prominence: prominence, size: size)
    }
}

extension ButtonStyle where Self == CueButtonStyle {
    public static var cuePrimary: CueButtonStyle { CueButtonStyle(.primary) }
    public static var cueSecondary: CueButtonStyle { CueButtonStyle(.secondary) }
}

private struct CueButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let prominence: CueButtonStyle.Prominence
    let size: CueButtonStyle.Size

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

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
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, CueSpacing.space2)
            .frame(minWidth: size.minimumWidth, minHeight: size.minimumHeight)
            .fixedSize(horizontal: false, vertical: true)
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
