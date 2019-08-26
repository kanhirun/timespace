import SwiftDate

extension TimePeriod: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "TimePeriod<[\(start?.toISO() ?? "∞") - \(end?.toISO() ?? "∞"))>"
    }
}
