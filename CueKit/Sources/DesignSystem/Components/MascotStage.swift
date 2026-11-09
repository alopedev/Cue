import SwiftUI

/// The character on its peach circle. Without the circle, the dark remote gets lost in dark mode.
public struct MascotStage: View {
    public enum Size: Sendable {
        /// Empty screens: 200 pt.
        case large
        /// Small notices: 120 pt.
        case small

        var points: CGFloat {
            switch self {
            case .large: 200
            case .small: 120
            }
        }
    }

    let image: Image
    let size: Size

    public init(_ image: Image, size: Size = .large) {
        self.image = image
        self.size = size
    }

    public var body: some View {
        Circle()
            .fill(CueColor.stage)
            .frame(width: size.points, height: size.points)
            .overlay {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.points * 0.78, height: size.points * 0.78)
            }
            .accessibilityHidden(true)
    }
}
