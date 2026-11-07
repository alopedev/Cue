#if DEBUG
    import SwiftUI

    /// Every piece of the design system on one screen. Debug builds only.
    public struct DesignSystemCatalog: View {
        public init() {}

        public var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: CueSpacing.lg) {
                    Text("¿Qué vemos hoy?").cueTextStyle(.display)
                    CatalogSection("Colores") { CatalogSwatches() }
                    CatalogSection("Letras") { CatalogTypography() }
                    CatalogSection("Botones") { CatalogButtons() }
                    CatalogSection("Tarjetas") { CatalogCards() }
                }
                .foregroundStyle(CueColor.ink)
                .padding(.horizontal, CueSpacing.md)
                .padding(.vertical, CueSpacing.xl)
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
            VStack(alignment: .leading, spacing: CueSpacing.sm) {
                Text(title).cueTextStyle(.title).accessibilityAddTraits(.isHeader)
                content
            }
        }
    }

    private struct CatalogSwatches: View {
        private let swatches: [(String, Color, Color)] = [
            ("canvas", CueColor.canvas, CueColor.ink),
            ("surface", CueColor.surface, CueColor.ink),
            ("surface-sunken", CueColor.surfaceSunken, CueColor.ink),
            ("cue", CueColor.cue, CueColor.onCue),
            ("ticket", CueColor.ticket, CueColor.onTicket),
            ("stage", CueColor.stage, CueColor.onTicket),
            ("success", CueColor.success, CueColor.surface),
            ("danger", CueColor.danger, CueColor.surface),
        ]

        var body: some View {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: CueSpacing.xs)], spacing: CueSpacing.xs) {
                ForEach(swatches, id: \.0) { name, fill, text in
                    Text(name)
                        .cueTextStyle(.caption)
                        .foregroundStyle(text)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(fill, in: RoundedRectangle(cornerRadius: CueRadius.small))
                        .overlay(RoundedRectangle(cornerRadius: CueRadius.small).stroke(CueColor.line))
                }
            }
        }
    }

    private struct CatalogTypography: View {
        var body: some View {
            VStack(alignment: .leading, spacing: CueSpacing.xs) {
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
            VStack(alignment: .leading, spacing: CueSpacing.sm) {
                Button("Recomiéndame") {}.buttonStyle(CueButtonStyle(.primary, fillsWidth: true))
                HStack(spacing: CueSpacing.sm) {
                    Button("Marcar visto") {}.buttonStyle(.cuePrimary)
                    Button("Ahora no") {}.buttonStyle(.cueSecondary)
                }
                Button("Desactivado") {}.buttonStyle(.cuePrimary).disabled(true)
            }
        }
    }

    private struct CatalogCards: View {
        var body: some View {
            VStack(spacing: CueSpacing.md) {
                CueCard(.ticket) {
                    VStack(alignment: .leading, spacing: CueSpacing.sm) {
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
                    VStack(alignment: .leading, spacing: CueSpacing.xxs) {
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
