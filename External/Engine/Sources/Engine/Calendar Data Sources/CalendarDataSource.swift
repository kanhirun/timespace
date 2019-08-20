import SwiftDate

public protocol CalendarDataSource {
    func timePeriods(from: DateInRegion,
                     until: DateInRegion,
                     onSuccess: @escaping ([TimePeriod]) -> Void,
                     onFailure: @escaping (Error) -> Void)
}
