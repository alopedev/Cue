import Foundation

/// The current date and time. Lets tests fix "now" to check rules such as "last 7 days".
///
/// Inside CueKit this name shadows the standard library's `Clock`; use `Swift.Clock` for that one.
public protocol Clock: Sendable {
    var now: Date { get }
}
