import SwiftDate

public protocol CalendarDataSource {
    
    func book(service: Service, period: TimePeriod) -> Bool
    
    func timePeriods(from: DateInRegion, until: DateInRegion) -> [TimePeriod]
}

public enum CalendarError: Error {
    case cannotSaveEvent
}
