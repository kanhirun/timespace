import Foundation
import SwiftDate

public class ServiceViewModel {
    
    var selectedService: Service? = nil
    public let services = [
        Service(name: "Men's Haircut", duration: 45.minutes),
        Service(name: "Chemical: Color", duration: 2.hours),
        Service(name: "Blowdry", duration: 1.hours + 30.minutes),
        Service(name: "Updo", duration: 1.hours),
    ]
    let filters: ScheduleService
    private let tag = "business-hours"
    
    public init() {
        filters = ScheduleService(start: DateInRegion(Date(), region: Region.local), duration: 3.months)
    }
    
    // MARK: - Actions
    
    public func requestAccess() {
        AppleCalendar().requestAccess()
    }

    public func select(_ pos: Int) {
        selectedService = services[pos]
        
        // TODO: This will likely be part of the Service, at some point.
        filters.min(only: .wednesday, .thursday, .friday, .saturday, .sunday, tag: tag)
            .min(only: (start: 9, end: 12 + 8), tag: tag)
    }
    
    public func unselect() {
        filters.remove(withTag: tag)
    }
}
