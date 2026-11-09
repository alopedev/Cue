import SwiftUI

/// A 2:3 poster with rounded corners and a solid edge underneath.
///
/// Until the real catalog brings images, it draws a sample poster from the title.
public struct CuePoster: View {
    let title: String
    let design: PosterDesign

    public init(title: String) {
        self.init(title: title, design: PosterDesign(title: title))
    }

    public init(title: String, design: PosterDesign) {
        self.title = title
        self.design = design
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: CueRadius.small, style: .continuous)
        Color.clear
            .aspectRatio(2 / 3, contentMode: .fit)
            .overlay { PosterArtwork(title: title, design: design) }
            .clipShape(shape)
            .background(alignment: .bottom) {
                shape.fill(CueColor.softEdge).offset(y: CueDepth.soft)
            }
            .padding(.bottom, CueDepth.soft)
            .accessibilityHidden(true)
    }
}

private struct PosterArtwork: View {
    let title: String
    let design: PosterDesign

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack(alignment: .bottomLeading) {
                Canvas { context, canvasSize in
                    PosterMotifDrawing(palette: design.palette, size: canvasSize).draw(design.motif, in: &context)
                }
                Text(title)
                    .font(.custom(CueFonts.titlePostScriptName, fixedSize: max(size.width * 0.125, 9)))
                    .tracking(-0.01 * size.width * 0.125)
                    .foregroundStyle(design.palette.text.swiftUIColor)
                    .lineLimit(3)
                    .minimumScaleFactor(0.6)
                    .padding(size.width * 0.08)
            }
            .background(design.palette.background.swiftUIColor)
        }
    }
}

/// Draws each motif in the top 62 % of the poster, leaving the bottom clear for the title.
private struct PosterMotifDrawing {
    let palette: PosterPalette
    let size: CGSize

    private var width: CGFloat { size.width }
    private var art: CGFloat { size.height * 0.62 }

    func draw(_ motif: PosterMotif, in context: inout GraphicsContext) {
        switch motif {
        case .sunset: drawSunset(in: &context)
        case .arcs: drawArcs(in: &context)
        case .orbits: drawOrbits(in: &context)
        case .stripes: drawStripes(in: &context)
        case .dots: drawDots(in: &context)
        case .moon: drawMoon(in: &context)
        }
    }

    private var primary: Color { palette.primary.swiftUIColor }
    private var secondary: Color { palette.secondary.swiftUIColor }
    private var background: Color { palette.background.swiftUIColor }

    private func circle(_ center: CGPoint, _ radius: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
    }

    private func drawSunset(in context: inout GraphicsContext) {
        let horizon = art * 0.86
        let radius = width * 0.36
        var sky = context
        sky.clip(to: Path(CGRect(x: 0, y: 0, width: width, height: horizon)))
        sky.fill(circle(CGPoint(x: width * 0.5, y: horizon - radius * 0.35), radius), with: .color(primary))
        for index in 0..<3 {
            let bandHeight = art * 0.025 * CGFloat(index + 1)
            let top = horizon - radius * 0.62 + CGFloat(index) * art * 0.085
            sky.fill(Path(CGRect(x: 0, y: top, width: width, height: bandHeight)), with: .color(background))
        }
        context.fill(
            Path(CGRect(x: width * 0.08, y: horizon, width: width * 0.84, height: art * 0.03)),
            with: .color(secondary)
        )
    }

    private func drawArcs(in context: inout GraphicsContext) {
        let corner = CGPoint(x: width * 1.02, y: art * 0.02)
        for index in 0..<4 {
            let radius = width * (0.28 + 0.2 * CGFloat(index))
            var arc = Path()
            arc.addArc(
                center: corner,
                radius: radius,
                startAngle: .degrees(90),
                endAngle: .degrees(180),
                clockwise: false
            )
            let color = index.isMultiple(of: 2) ? primary : secondary
            context.stroke(arc, with: .color(color), style: StrokeStyle(lineWidth: width * 0.09, lineCap: .butt))
        }
    }

    private func drawOrbits(in context: inout GraphicsContext) {
        let center = CGPoint(x: width * 0.52, y: art * 0.5)
        var rotated = context
        rotated.translateBy(x: center.x, y: center.y)
        rotated.rotate(by: .degrees(-24))
        for scale in [0.82, 1.18] {
            let ring = Path(
                ellipseIn: CGRect(
                    x: -width * 0.4 * scale,
                    y: -width * 0.14 * scale,
                    width: width * 0.8 * scale,
                    height: width * 0.28 * scale
                )
            )
            rotated.stroke(ring, with: .color(primary), lineWidth: width * 0.025)
        }
        context.fill(circle(center, width * 0.17), with: .color(secondary))
        context.fill(circle(CGPoint(x: width * 0.84, y: art * 0.26), width * 0.05), with: .color(primary))
    }

    private func drawStripes(in context: inout GraphicsContext) {
        var clipped = context
        clipped.clip(to: Path(CGRect(x: 0, y: 0, width: width, height: art * 0.92)))
        let band = width * 0.12
        for index in -4..<8 {
            let offset = CGFloat(index) * band * 2
            var stripe = Path()
            stripe.move(to: CGPoint(x: offset, y: 0))
            stripe.addLine(to: CGPoint(x: offset + band, y: 0))
            stripe.addLine(to: CGPoint(x: offset + band + art, y: art))
            stripe.addLine(to: CGPoint(x: offset + art, y: art))
            stripe.closeSubpath()
            clipped.fill(stripe, with: .color(index == 2 ? secondary : primary))
        }
    }

    private func drawDots(in context: inout GraphicsContext) {
        let columns = 5
        let spacing = width / CGFloat(columns)
        let rows = Int(art / spacing)
        for row in 0..<rows {
            for column in 0..<columns {
                let center = CGPoint(x: spacing * (CGFloat(column) + 0.5), y: spacing * (CGFloat(row) + 0.5))
                let isAccent = row == rows / 2 && column == columns - 2
                context.fill(
                    circle(center, isAccent ? spacing * 0.42 : spacing * 0.18),
                    with: .color(isAccent ? secondary : primary)
                )
            }
        }
    }

    private func drawMoon(in context: inout GraphicsContext) {
        let center = CGPoint(x: width * 0.46, y: art * 0.5)
        let radius = width * 0.3
        context.fill(circle(center, radius), with: .color(primary))
        context.fill(
            circle(CGPoint(x: center.x + radius * 0.45, y: center.y - radius * 0.3), radius * 0.9),
            with: .color(background)
        )
        let stars: [(CGFloat, CGFloat, CGFloat)] = [
            (0.8, 0.22, 0.03), (0.68, 0.72, 0.022), (0.16, 0.18, 0.025), (0.88, 0.55, 0.018),
        ]
        for (x, y, size) in stars {
            context.fill(circle(CGPoint(x: width * x, y: art * y), width * size), with: .color(secondary))
        }
    }
}

extension RGBColor {
    var swiftUIColor: Color { Color(.sRGB, red: red, green: green, blue: blue) }
}
