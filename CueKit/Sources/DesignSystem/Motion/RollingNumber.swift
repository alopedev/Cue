import SwiftUI

extension View {
    /// Makes a number roll to its new value instead of jumping, like a departures board.
    ///
    /// `value` is the number the text shows; it sets the direction of the roll (up or down).
    /// With «Reducir movimiento» the old number fades into the new one instead.
    public func cueRollingNumber(_ value: Double) -> some View {
        modifier(RollingNumber(value: value))
    }
}

private struct RollingNumber: ViewModifier {
    let value: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .contentTransition(reduceMotion ? .opacity : .numericText(value: value))
            .animation(reduceMotion ? .easeInOut(duration: 0.2) : .snappy(duration: 0.35), value: value)
    }
}
