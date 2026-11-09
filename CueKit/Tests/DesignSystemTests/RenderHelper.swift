import SwiftUI

/// Draws a view off screen at one pixel per point, so sizes can be checked in points.
@MainActor
func render(_ view: some View) -> CGImage? {
    let renderer = ImageRenderer(content: view)
    renderer.scale = 1
    return renderer.cgImage
}
