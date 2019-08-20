import SwiftDate
import EventKit

public class AppleCalendar: CalendarDataSource {
    
    private let store = EKEventStore()
    
    /// Indicates whether the user has authorized the app to use their calendar
    private var hasConsented = false
    
    public init() {}
    
    public func requestAccess() {
        store.requestAccess(to: .event) { hasConsented, err in
            debugPrint(hasConsented, err as Any)
        }
    }
    
    public func timePeriods(from: DateInRegion,
                     until: DateInRegion,
                     onSuccess: @escaping ([TimePeriod]) -> Void,
                     onFailure: @escaping (Error) -> Void) {

        
        // Retrieve events from all calendars
        let predicate = store.predicateForEvents(withStart: from.date,
                                                 end: until.date,
                                                 calendars: allCalendars())

        let results = store.events(matching: predicate)
            // By default, the events come out un-ordered, so we must sort them
            .sorted(by: { e1, e2 in
                e1.startDate.compare(e2.startDate) == .orderedAscending
            })
            // Filter by occupied time periods
            .filter { event in
                let criteria: [EKEventAvailability] = [.busy, .tentative, .unavailable]
                return criteria.contains(event.availability)
            }
            .map { event in
                TimePeriod(startDate: event.startDate, endDate: event.endDate)
            }

        onSuccess(results)
    }
    
    
    // Retrieves all existing calendars from user
    private func allCalendars() -> [EKCalendar] {
        var all = Set<EKCalendar>()
        
        store.sources.forEach { aSource in
            all = all.union(aSource.calendars(for: .event))
        }

        return Array(all)
    }
}
