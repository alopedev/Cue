import CueKit
import DesignSystem
import SwiftUI

/// Three columns of posters with the name and state under each one (design system: LibraryGrid).
struct LibraryGrid: View {
    let entries: [LibraryEntry]
    let library: LibraryModel
    let open: (TitleID) -> Void

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: CueSpacing.space3, alignment: .top),
        count: 3
    )

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: CueSpacing.space4) {
            ForEach(entries) { entry in
                Button {
                    open(entry.id)
                } label: {
                    LibraryTile(entry: entry)
                }
                .buttonStyle(TileButtonStyle())
                .contextMenu { markAction(for: entry) }
                .accessibilityIdentifier("tile.\(entry.title)")
            }
        }
    }

    @ViewBuilder
    private func markAction(for entry: LibraryEntry) -> some View {
        switch entry {
        case .series(let series):
            if let next = series.progress.currentEpisode {
                Button {
                    Task { await library.markNextEpisode(of: series.id) }
                } label: {
                    Label("Marcar visto \(LibraryText.episodeCode(next.id))", systemImage: "checkmark.circle")
                }
            }
        case .movie(let movie):
            if movie.tracking.status != .watched {
                Button {
                    Task { await library.markWatched(movie.id) }
                } label: {
                    Label("Marcar vista", systemImage: "checkmark.circle")
                }
            }
        }
    }
}

/// One title of the grid: poster, name (two lines reserved, so rows stay aligned) and state.
struct LibraryTile: View {
    let entry: LibraryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: CueSpacing.space1) {
            CuePoster(title: entry.title)
                .overlay(alignment: .bottom) { posterBadge.padding(.bottom, CueDepth.soft) }
            Text(entry.title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(CueColor.ink)
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.leading)
                .padding(.top, CueSpacing.space1)
            Text(LibraryText.tileState(entry))
                .cueTextStyle(.caption)
                .foregroundStyle(CueColor.inkMuted)
                .lineLimit(1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLabel)
        .accessibilityAddTraits(.isButton)
    }

    @ViewBuilder
    private var posterBadge: some View {
        switch entry {
        case .series(let series) where series.tracking.status == .watching:
            ProgressCapsule(fraction: series.progress.fractionWatched)
                .padding(CueSpacing.space2)
        case .series(let series) where series.tracking.status == .finished:
            DoneBadge()
        case .movie(let movie) where movie.tracking.status == .watched:
            DoneBadge()
        default:
            EmptyView()
        }
    }

    private var spokenLabel: String {
        switch entry {
        case .series(let series):
            let status = LibraryText.seriesStatus(series.tracking.status).lowercased()
            guard series.tracking.status == .watching, let next = series.progress.currentEpisode else {
                return "\(entry.title), serie, \(status)"
            }
            return "\(entry.title), serie, viendo, \(LibraryText.spokenEpisode(next.id))"
        case .movie(let movie):
            return "\(entry.title), película, \(LibraryText.movieStatus(movie.tracking.status).lowercased())"
        }
    }
}

/// The watched share of a series, as a bar on its poster (RF-35).
struct ProgressCapsule: View {
    let fraction: Double

    var body: some View {
        GeometryReader { proxy in
            Capsule()
                .fill(CueColor.surface.opacity(0.9))
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(CueColor.cue)
                        .frame(width: max(proxy.size.height, proxy.size.width * fraction))
                }
        }
        .frame(height: 6)
        .accessibilityHidden(true)
    }
}

/// The ✓ in the corner of a watched poster. The word «Vista» goes under the poster too.
struct DoneBadge: View {
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(CueColor.surface)
                .frame(width: 24, height: 24)
                .background(Circle().fill(CueColor.success))
                .padding(CueSpacing.space1)
        }
        .accessibilityHidden(true)
    }
}

/// A tile sinks a little while touched, like the rest of Cue's pieces.
struct TileButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .opacity(configuration.isPressed && reduceMotion ? 0.8 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
