import SwiftDate
import Foundation
import Engine

class CalendarViewModel {
    
    private var selectedPeriods =  [TimePeriod]()
    
    private var filters: Filters
    
    // TODO: Should derive from filters.
    let startDate = Date("2019-08-19T00:00:00Z")!
    let endDate   = Date("2019-08-25T00:00:00Z")!

    init(from model: ServiceViewModel) {
        filters = model.filters
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
}
