import CueKit
import DesignSystem
import SwiftUI

/// After each mark, a capsule offers to undo it for 10 seconds, with a ring that runs out (RF-33).
struct UndoToast: View {
    let library: LibraryModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.2)) { context in
            if let undo = library.pendingUndo, undo.expiresAt > context.date {
                let remaining = undo.expiresAt.timeIntervalSince(context.date) / LibraryModel.undoWindow
                toast(for: undo, remaining: remaining)
                    .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.8), value: library.pendingUndo)
    }

    private func toast(for undo: PendingUndo, remaining: Double) -> some View {
        HStack(spacing: CueSpacing.space3) {
            Image(systemName: undo.unmarked.isEmpty ? "checkmark" : "arrow.uturn.backward")
                .font(.system(size: 13, weight: .heavy))
                .foregroundStyle(CueColor.onCue)
                .frame(width: 28, height: 28)
                .background(Circle().fill(CueColor.cue))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 0) {
                Text(message(for: undo))
                    .cueTextStyle(.callout)
                    .foregroundStyle(CueColor.ink)
                Text(undo.title)
                    .cueTextStyle(.caption)
                    .foregroundStyle(CueColor.inkMuted)
            }
            .lineLimit(1)
            Spacer(minLength: CueSpacing.space2)
            UndoButton(remaining: remaining) { Task { await library.undo() } }
        }
        .padding(.leading, CueSpacing.space3)
        .padding(.trailing, CueSpacing.space2)
        .padding(.vertical, CueSpacing.space2)
        .background(Capsule().fill(CueColor.surface))
        .overlay(Capsule().strokeBorder(CueColor.line, lineWidth: 1))
        .background(alignment: .bottom) {
            Capsule().fill(CueColor.softEdge).offset(y: CueDepth.soft)
        }
        .padding(.horizontal, CueSpacing.space4)
        .padding(.bottom, CueSpacing.space4)
        .accessibilityElement(children: .contain)
    }

    private func message(for undo: PendingUndo) -> String {
        if undo.isMovie { return "Película vista" }
        if let episode = undo.marked.first, undo.marked.count == 1 {
            return "Visto \(LibraryText.episodeCode(episode))"
        }
        if undo.marked.count > 1 { return "\(undo.marked.count) episodios vistos" }
        return "Episodio sin marcar"
    }
}

/// «Deshacer» with the ring that shows the time left.
private struct UndoButton: View {
    let remaining: Double
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: CueSpacing.space2) {
                CountdownRing(remaining: remaining)
                Text("Deshacer")
                    .font(.subheadline.weight(.bold))
            }
            .foregroundStyle(CueColor.ink)
            .padding(.horizontal, CueSpacing.space3)
            .frame(minHeight: 44)
            .background(Capsule().fill(CueColor.surfaceSunken))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("undo.button")
    }
}

/// A small ring that empties as the undo time runs out.
private struct CountdownRing: View {
    let remaining: Double

    var body: some View {
        ZStack {
            Circle().stroke(CueColor.line, lineWidth: 2.5)
            Circle()
                .trim(from: 0, to: max(0, min(1, remaining)))
                .stroke(CueColor.cue, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.2), value: remaining)
        }
        .frame(width: 16, height: 16)
        .accessibilityHidden(true)
    }
}
