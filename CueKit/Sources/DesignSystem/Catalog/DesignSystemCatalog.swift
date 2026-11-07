#if DEBUG
    import SwiftUI

    /// Every piece of the design system on one screen. Debug builds only.
    public struct DesignSystemCatalog: View {
        public init() {}

        public var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: CueSpacing.space6) {
                    Text("¿Qué vemos hoy?").cueTextStyle(.display)
                    CatalogSection("Colores") { CatalogSwatches() }
                    CatalogSection("Letras") { CatalogTypography() }
                    CatalogSection("Botones") { CatalogButtons() }
                    CatalogSection("Tarjetas") { CatalogCards() }
                }
                .foregroundStyle(CueColor.ink)
                .padding(.horizontal, CueSpacing.space4)
                .padding(.vertical, CueSpacing.space8)
            }
            .background(CueColor.canvas)
        }
    }

    private struct CatalogSection<Content: View>: View {
        let title: String
        let content: Content

        init(_ title: String, @ViewBuilder content: () -> Content) {
            self.title = title
            self.content = content()
        }

        var body: some View {
            VStack(alignment: .leading, spacing: CueSpacing.space3) {
                Text(title).cueTextStyle(.title).accessibilityAddTraits(.isHeader)
                content
            }
        }
    }

    private struct Swatch {
        let name: String
        let fill: Color
        let text: Color
    }

    private struct CatalogSwatches: View {
        private let swatches: [Swatch] = [
            Swatch(name: "canvas", fill: CueColor.canvas, text: CueColor.ink),
            Swatch(name: "surface", fill: CueColor.surface, text: CueColor.ink),
            Swatch(name: "surface-sunken", fill: CueColor.surfaceSunken, text: CueColor.ink),
            Swatch(name: "cue", fill: CueColor.cue, text: CueColor.onCue),
            Swatch(name: "ticket", fill: CueColor.ticket, text: CueColor.onTicket),
            Swatch(name: "stage", fill: CueColor.stage, text: CueColor.onTicket),
            Swatch(name: "success", fill: CueColor.success, text: CueColor.surface),
            Swatch(name: "danger", fill: CueColor.danger, text: CueColor.surface),
        ]

        var body: some View {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: CueSpacing.space2), count: 2),
                spacing: CueSpacing.space2
            ) {
                ForEach(swatches, id: \.name) { swatch in
                    Text(swatch.name)
                        .cueTextStyle(.caption)
                        .foregroundStyle(swatch.text)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(swatch.fill, in: RoundedRectangle(cornerRadius: CueRadius.small))
                        .overlay(RoundedRectangle(cornerRadius: CueRadius.small).stroke(CueColor.line))
                }
            }
        }
    }

    private struct CatalogTypography: View {
        var body: some View {
            VStack(alignment: .leading, spacing: CueSpacing.space2) {
                Text("Biblioteca").cueTextStyle(.title)
                Text("Título de ejemplo").cueTextStyle(.ticketTitle)
                Text("Cabe en tu hora y la dejaste hace 3 días.").cueTextStyle(.why)
                Text("Toca las plataformas que tengas.").cueTextStyle(.body)
                Text("Marcar visto").cueTextStyle(.label)
                Text("T2 · E5").cueTextStyle(.callout).foregroundStyle(CueColor.inkMuted)
                Text("48 min").cueTextStyle(.minutes)
                Text("15 h 12 min").cueTextStyle(.minutesLarge)
                Text("Disponibilidad: JustWatch").cueTextStyle(.caption).foregroundStyle(CueColor.inkMuted)
            }
        }
    }

    private struct CatalogButtons: View {
        var body: some View {
            VStack(alignment: .leading, spacing: CueSpacing.space3) {
                Button("Recomiéndame") {}.buttonStyle(CueButtonStyle(.primary, fillsWidth: true))
                HStack(spacing: CueSpacing.space3) {
                    Button("Marcar visto") {}.buttonStyle(.cuePrimary)
                    Button("Ahora no") {}.buttonStyle(.cueSecondary)
                }
                Button("Desactivado") {}.buttonStyle(.cuePrimary).disabled(true)
            }
        }
    }

    private struct CatalogCards: View {
        var body: some View {
            VStack(spacing: CueSpacing.space4) {
                CueCard(.ticket) {
                    VStack(alignment: .leading, spacing: CueSpacing.space3) {
                        ConcentricRectangle()
                            .fill(CueColor.onTicket.opacity(0.85))
                            .frame(height: 120)
                            .accessibilityHidden(true)
                        Text("Título de ejemplo").cueTextStyle(.ticketTitle)
                        Text("Serie · T2 · E5 · 48 min").cueTextStyle(.minutes).foregroundStyle(CueColor.onTicketMuted)
                        Text("Cabe en tu hora y la dejaste hace 3 días.").cueTextStyle(.why)
                        Text("Disponibilidad: JustWatch").cueTextStyle(.caption)
                            .foregroundStyle(CueColor.onTicketMuted)
                    }
                }
                .accessibilityElement(children: .combine)
                CueCard(.surface) {
                    VStack(alignment: .leading, spacing: CueSpacing.space1) {
                        Text("Tarjeta normal").cueTextStyle(.label)
                        Text("Para fichas y celdas sobre el fondo.").cueTextStyle(.body)
                            .foregroundStyle(CueColor.inkMuted)
                    }
                }
            }
        }
    }

    #Preview("Claro") { DesignSystemCatalog().preferredColorScheme(.light) }
    #Preview("Oscuro") { DesignSystemCatalog().preferredColorScheme(.dark) }
#endif
