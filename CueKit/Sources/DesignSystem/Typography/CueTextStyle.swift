import SwiftUI

/// Text styles of the design system. All of them grow with the iPhone text size (Dynamic Type).
public enum CueTextStyle: CaseIterable, Sendable {
    /// Title of «Esta noche». Once per screen.
    case display
    /// Screen titles.
    case title
    /// Name of the show or film on a ticket.
    case ticketTitle
    /// The «why» sentence. Never truncated.
    case why
    case body
    /// Button text.
    case label
    /// Secondary data in rows.
    case callout
    /// Attribution and notes. Nothing goes smaller.
    case caption
    /// Durations, with fixed-width digits.
    case minutes
    /// Large chosen or remaining time.
    case minutesLarge

    /// Size at the default text size, before Dynamic Type scaling.
    public var baseSize: CGFloat {
        switch self {
        case .display: 40
        case .title: 28
        case .ticketTitle: 24
        case .why, .body, .label: 17
        case .callout, .minutes: 15
        case .caption: 12
        case .minutesLarge: 34
        }
    }

    public var font: Font {
        switch self {
        case .display: titleFont(relativeTo: .largeTitle)
        case .title: titleFont(relativeTo: .title)
        case .ticketTitle: titleFont(relativeTo: .title2)
        case .why: .body.weight(.semibold)
        case .body: .body
        case .label: .headline.weight(.bold)
        case .callout: .subheadline.weight(.medium)
        case .caption: .caption.weight(.medium)
        case .minutes: .system(.subheadline, design: .monospaced, weight: .medium)
        case .minutesLarge: .system(.largeTitle, design: .monospaced, weight: .semibold)
        }
    }

    /// Letter spacing, in points at the base size.
    public var tracking: CGFloat {
        switch self {
        case .display: -0.02 * baseSize
        case .title: -0.01 * baseSize
        default: 0
        }
    }

    private func titleFont(relativeTo style: Font.TextStyle) -> Font {
        .custom(CueFonts.titlePostScriptName, size: baseSize, relativeTo: style)
    }
}

extension View {
    /// Applies a design-system text style.
    public func cueTextStyle(_ style: CueTextStyle) -> some View {
        font(style.font).tracking(style.tracking).monospacedDigit()
    }
}
