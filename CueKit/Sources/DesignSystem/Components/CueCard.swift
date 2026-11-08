import SwiftUI

/// A card with rounded corners and a solid edge underneath.
///
/// Shapes placed inside can use `ConcentricRectangle()` or `CueCard.innerRadius`
/// so their corners stay concentric with the card's (RNF-11).
public struct CueCard<Content: View>: View {
    public enum Style: Sendable {
        /// Mint ticket of «Esta noche».
        case ticket
        /// Plain card on `canvas`.
        case surface
    }

    /// Corner radius for a shape nested inside the card's padding.
    public static var innerRadius: CGFloat {
        CueRadius.concentric(outer: CueRadius.large, inset: CueSpacing.space4)
    }

    let style: Style
    let content: Content

    public init(_ style: Style = .surface, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: CueRadius.large, style: .continuous)
        content
            .foregroundStyle(colors.text)
            .padding(CueSpacing.space4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(shape.fill(colors.fill))
            .containerShape(shape)
            .background(alignment: .bottom) {
                shape.fill(colors.edge).offset(y: depth)
            }
            .padding(.bottom, depth)
    }

    private var depth: CGFloat {
        switch style {
        case .ticket: CueDepth.card
        case .surface: CueDepth.soft
        }
    }

    private var colors: PieceColors {
        switch style {
        case .ticket: PieceColors(fill: CueColor.ticket, text: CueColor.onTicket, edge: CueColor.ticketEdge)
        case .surface: PieceColors(fill: CueColor.surface, text: CueColor.ink, edge: CueColor.softEdge)
        }
    }
}
