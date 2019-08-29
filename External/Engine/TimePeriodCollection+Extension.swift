@testable import SwiftDate

extension TimePeriodCollection {
    func periodsEnclosing(period: TimePeriod) -> TimePeriodCollection {
        return TimePeriodCollection(periods.filter { $0.encloses(with: period) })
    }
}
