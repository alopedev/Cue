import SwiftUI

/// A row of Cue buttons that all take the width of the widest one, so a pair lines up.
public struct CueButtonRow<Content: View>: View {
    let spacing: CGFloat
    let content: Content

    public init(spacing: CGFloat = CueSpacing.space3, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        EqualWidthLayout(spacing: spacing) { content }
            .environment(\.cueButtonFillsRowCell, true)
    }
}

extension EnvironmentValues {
    /// Inside a `CueButtonRow`, buttons widen to the shared cell instead of hugging their text.
    @Entry var cueButtonFillsRowCell = false
}

/// Places pieces side by side, each as wide as the widest one's ideal width.
struct EqualWidthLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }
        let cell = cellSize(of: subviews)
        let gaps = spacing * CGFloat(subviews.count - 1)
        return CGSize(width: cell.width * CGFloat(subviews.count) + gaps, height: cell.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let cell = cellSize(of: subviews)
        var originX = bounds.minX
        for subview in subviews {
            subview.place(
                at: CGPoint(x: originX, y: bounds.minY),
                proposal: ProposedViewSize(width: cell.width, height: cell.height)
            )
            originX += cell.width + spacing
        }
    }

    private func cellSize(of subviews: Subviews) -> CGSize {
        subviews.map { $0.sizeThatFits(.unspecified) }.reduce(.zero) {
            CGSize(width: max($0.width, $1.width), height: max($0.height, $1.height))
        }
    }
}
