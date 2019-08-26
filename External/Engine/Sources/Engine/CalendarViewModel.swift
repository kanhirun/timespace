import SwiftDate
import Foundation

public class CalendarViewModel {
    
    public var selectedPeriods =  [TimePeriod]()
    public let start: DateInRegion
    public let end: DateInRegion
    
    private var filters: TimePeriodFilter
    private let tag = "CalendarViewModel"
    private let service: Service
    
    private let calendar = AppleCalendar()

    public init(from model: ServiceViewModel) {
        filters = model.filters
        service = model.selectedService!
        start = model.filters.start
        end = model.filters.end
    }
    
    // MARK: - Actions

    public func getResultsToSend(completion: @escaping (Result<([TimePeriod], URLComponents), Error>) -> Void) {
        // 1. Returns availability against dates picked
        filters.min(only: selectedPeriods, tag: tag)
        // 2. Remove any time periods which are already occupied
               .subtract(fromSource: calendar, tag: tag) { result in
                    let newResults = result.flatMap { filter -> Result<([TimePeriod], URLComponents), Error> in
                    
        // 3. Break down options for times that are service-length long
                    let periods = filter.quantize(unit: self.service.duration, tag: self.tag)
        // 4. Show results based on user timezone
                                        .apply(region: Region.local)

                    // Package the results into query items for messaging
                    var components = URLComponents()
                    components.queryItems = [
                        URLQueryItem(name: "data", value: periods.toJSON().rawString()),
                        URLQueryItem(name: "service", value: self.service.toJSON().rawString()),
                    ]

                    return Result { (periods, components) }
                }
                completion(newResults)
            }
    }
    
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
}
