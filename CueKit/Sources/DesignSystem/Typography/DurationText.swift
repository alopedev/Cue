/// Durations as the app writes them: always with their unit, such as «48 min» or «1 h 52 min».
public enum DurationText {
    public static func string(minutes: Int) -> String {
        let hours = minutes / 60
        let rest = minutes % 60
        switch (hours, rest) {
        case (0, _): return "\(rest) min"
        case (_, 0): return "\(hours) h"
        default: return "\(hours) h \(rest) min"
        }
    }
}
