import SwiftDate
import Foundation

public class CalendarViewModel {
    
    public var selectedPeriods =  [TimePeriod]()
    
    public var filters: Filters
    
    public let start: DateInRegion
    public let end: DateInRegion

    public init(from model: ServiceViewModel) {
        filters = model.filters
        start = model.filters!.start
        end = model.filters!.end
    }
    
    // MARK: - Actions
    
    public func select(_ aDate: Date) {
        let aDateInRegion = aDate.convertTo(region: Region.local).dateAtStartOf(.day)
        let aPeriod = TimePeriod(startDate: aDateInRegion.date,
                                 endDate: aDateInRegion.dateByAdding(1, .day).date)

        selectedPeriods.append(aPeriod)
    }
    
    public func unselect(_ aDate: Date) {
        selectedPeriods.removeAll { period -> Bool in
            period.start?.day == aDate.day
        }
    }
    
    public func applySelections() {
        _ = filters.min(only: selectedPeriods, tag: "CalendarViewModel")
    }
}
