import SwiftDate
import Foundation
import Engine

class CalendarViewModel {
    
    var selectedPeriods =  [TimePeriod]()
    
    var filters: Filters
    
    let start: DateInRegion
    let end: DateInRegion

    init(from model: ServiceViewModel) {
        filters = model.filters
        start = model.filters!.start
        end = model.filters!.end
    }
    
    // MARK: - Actions
    
    func select(_ aDate: Date) {
        let aDateInRegion = aDate.convertTo(region: Region.local).dateAtStartOf(.day)
        let aPeriod = TimePeriod(startDate: aDateInRegion.date,
                                 endDate: aDateInRegion.dateByAdding(1, .day).date)

        selectedPeriods.append(aPeriod)
    }
    
    func unselect(_ aDate: Date) {
        selectedPeriods.removeAll { period -> Bool in
            period.start?.day == aDate.day
        }
    }
    
    func apply() {
        filters.min(only: selectedPeriods, tag: "CalendarViewModel")
    }
}
