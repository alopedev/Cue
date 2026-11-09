import DesignSystem
import SwiftUI

/// How long it takes to catch up with every series being watched (RF-37).
struct CatchUpCard: View {
    let minutes: Int
    let seriesCount: Int

    var body: some View {
        CueCard(.surface) {
            HStack(alignment: .center, spacing: CueSpacing.space4) {
                VStack(alignment: .leading, spacing: CueSpacing.space1) {
                    Text("Para ponerte al día")
                        .cueTextStyle(.callout)
                        .foregroundStyle(CueColor.inkMuted)
                    Text(DurationText.string(minutes: minutes))
                        .cueTextStyle(.minutesLarge)
                        .foregroundStyle(CueColor.ink)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    Text(
                        seriesCount == 1
                            ? "con la serie que estás viendo" : "con las \(seriesCount) series que estás viendo"
                    )
                    .cueTextStyle(.caption)
                    .foregroundStyle(CueColor.inkMuted)
                }
                Spacer(minLength: 0)
                Image(systemName: "clock")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(CueColor.cue)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(CueColor.surfaceSunken))
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("library.catchUp")
    }
}
