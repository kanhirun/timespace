import SwiftDate

public protocol CalendarDataSource {
    
    func book(service: Service, period: TimePeriod) -> Bool
    
    func timePeriods(from: DateInRegion,
                     until: DateInRegion,
                     onSuccess: @escaping ([TimePeriod]) -> Void,
                     onFailure: @escaping (Error) -> Void)
}

public enum CalendarError: Error {
    case cannotSaveEvent
}
