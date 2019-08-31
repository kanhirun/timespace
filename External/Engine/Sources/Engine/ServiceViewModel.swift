import Foundation
import SwiftDate


public class ServiceViewModel {
    
    public let services = [
        Service(name: "Men's Haircut", duration: 45.minutes),
        Service(name: "Chemical: Color", duration: 2.hours),
        Service(name: "Blowdry", duration: 1.hours + 30.minutes),
        Service(name: "Updo", duration: 1.hours),
    ]

    public let scheduleService: ScheduleService
    private var serviceRepository: ServiceRepository
    private let calendarService: AppleCalendar
    private let tag = "\(ServiceViewModel.self)"
    
    public init(serviceRepository: ServiceRepository = ServiceRepository.shared,
                calendarService: AppleCalendar = AppleCalendar.shared) {
        self.calendarService = calendarService
        self.serviceRepository = serviceRepository
        self.scheduleService = ScheduleService(start: DateInRegion(Date(), region: Region.local), duration: 3.months)
    }
    
    // MARK: - Actions
    
    public func requestAccess() {
        calendarService.requestAccess()
    }

    public func select(_ pos: Int) {
        serviceRepository.value = services[pos]
        
        // TODO: This will likely be part of the Service, at some point.
        scheduleService.min(only: .wednesday, .thursday, .friday, .saturday, .sunday, tag: tag)
                       .min(only: (start: 9, end: 12 + 8), tag: tag)
    }
    
    public func unselect() {
        scheduleService.remove(withTag: tag)
    }
}
