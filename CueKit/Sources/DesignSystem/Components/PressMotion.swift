import CoreGraphics
import SwiftUI

/// Where a raised piece sits while it is touched: it sinks onto its edge like a key.
///
/// With Reduce Motion nothing moves (RNF-12): the edge disappears and the piece dims instead.
struct PressMotion: Equatable {
    /// Vertical displacement of the piece.
    let offset: CGFloat
    /// Visible height of the solid edge under the piece.
    let edgeHeight: CGFloat
    let opacity: Double
    let animation: Animation?

    init(depth: CGFloat, isPressed: Bool, reduceMotion: Bool) {
        offset = isPressed && !reduceMotion ? depth : 0
        edgeHeight = isPressed ? 0 : depth
        opacity = isPressed && reduceMotion ? 0.8 : 1
        animation = reduceMotion ? nil : .easeOut(duration: 0.12)
    }
}
