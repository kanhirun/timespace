import SwiftDate
import Foundation
import Engine

class ServiceViewModel {

    var selectedService: Service? = nil
    let services = [
        Service(name: "Men's Haircut", duration: 45.minutes),
        Service(name: "Chemical: Color", duration: 2.hours),
        Service(name: "Blowdry", duration: 1.hours + 30.minutes),
        Service(name: "Updo", duration: 1.hours),
    ]
    
    var filters: Filters! = nil
    
    private let tag = "business-hours"

    init() {
        filters = Filters(start: DateInRegion(Date(), region: Region.local), duration: 2.weeks)
    }
    
    // MARK: - Actions

    func select(_ pos: Int) {
        selectedService = services[pos]

        // TODO: This will likely be part of the Service, at some point.
        filters.min(only: .wednesday, .thursday, .friday, .saturday, .sunday, tag: tag)
                .min(only: (start: 9, end: 12 + 8), tag: tag)
    }

    func unselect() {
        filters.remove(withTag: tag)
    }
}

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
