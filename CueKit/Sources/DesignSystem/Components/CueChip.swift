import SwiftUI

/// A capsule the user taps to choose one option among several: shelves, time, mood.
///
/// The chosen one fills with coral and rises 2 points on its edge, so the choice
/// never depends on color alone.
public struct CueChip: View {
    let title: String
    let count: Int?
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(_ title: String, count: Int? = nil, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.count = count
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: CueSpacing.space2) {
                Text(title)
                if let count {
                    Text("\(count)")
                        .monospacedDigit()
                        .foregroundStyle(isSelected ? CueColor.onCue.opacity(0.8) : CueColor.inkMuted)
                }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isSelected ? CueColor.onCue : CueColor.ink)
            .padding(.horizontal, CueSpacing.space4)
            .frame(minHeight: 44)
            .background(Capsule().fill(isSelected ? CueColor.cue : CueColor.surface))
            .overlay(Capsule().strokeBorder(isSelected ? CueColor.cue : CueColor.line, lineWidth: 2))
            .offset(y: isSelected && !reduceMotion ? -2 : 0)
            .background(alignment: .bottom) {
                Capsule().fill(isSelected ? CueColor.cueEdge : CueColor.softEdge).offset(y: CueDepth.soft)
            }
            .padding(.bottom, CueDepth.soft)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(reduceMotion ? nil : .spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityLabel(count.map { "\(title), \($0)" } ?? title)
    }
}
