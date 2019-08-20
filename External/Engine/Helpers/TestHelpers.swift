import Foundation
import SwiftDate

// Use this for testing by focusing on simple numbers
func aPeriod(_ from: TimeInterval, _ to: TimeInterval) -> TimePeriod {
    return TimePeriod(startDate: Date(timeIntervalSince1970: from), endDate: Date(timeIntervalSince1970: to))
}
