import CueKit
import DesignSystem
import SwiftUI

/// One episode in a series' sheet, with its round check to mark or unmark it.
struct EpisodeRow: View {
    let episode: Episode
    let isWatched: Bool
    let hasAired: Bool
    let toggle: () -> Void
    let markThrough: () -> Void

    var body: some View {
        HStack(spacing: CueSpacing.space3) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(episode.id.episodeNumber). \(episode.title)")
                    .cueTextStyle(.body)
                    .foregroundStyle(hasAired ? CueColor.ink : CueColor.inkMuted)
                Text(detail)
                    .cueTextStyle(.caption)
                    .foregroundStyle(CueColor.inkMuted)
            }
            Spacer(minLength: CueSpacing.space2)
            if hasAired {
                WatchedCheck(isWatched: isWatched, action: toggle)
            }
        }
        .frame(minHeight: 44)
        .contextMenu {
            if hasAired {
                Button(action: markThrough) {
                    Label("Marcar hasta aquí", systemImage: "checkmark.circle.badge.questionmark")
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Episodio \(episode.id.episodeNumber), \(episode.title)")
        .accessibilityValue(hasAired ? (isWatched ? "visto" : "sin ver") : detail)
        .accessibilityAction(named: isWatched ? "Desmarcar" : "Marcar visto", toggle)
        .accessibilityAction(named: "Marcar hasta aquí", markThrough)
    }

    private var detail: String {
        guard hasAired else {
            return episode.airDate.map { "Se estrena el \(LibraryText.shortDate($0))" } ?? "Sin fecha de estreno"
        }
        var parts: [String] = []
        if let minutes = episode.runtimeMinutes { parts.append(DurationText.string(minutes: minutes)) }
        if let date = episode.airDate { parts.append(LibraryText.shortDate(date)) }
        return parts.joined(separator: " · ")
    }
}

/// The 44-point round check: coral and filled once watched.
struct WatchedCheck: View {
    let isWatched: Bool
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .strokeBorder(CueColor.line, lineWidth: 2)
                    .opacity(isWatched ? 0 : 1)
                Circle()
                    .fill(CueColor.cue)
                    .scaleEffect(isWatched ? 1 : 0.4)
                    .opacity(isWatched ? 1 : 0)
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(CueColor.onCue)
                    .opacity(isWatched ? 1 : 0)
            }
            .frame(width: 30, height: 30)
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(reduceMotion ? nil : .spring(response: 0.25, dampingFraction: 0.6), value: isWatched)
        .accessibilityLabel(isWatched ? "Visto" : "Marcar visto")
    }
}
