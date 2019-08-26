import SwiftDate
import Foundation

public class CalendarViewModel {
    
    public var selectedPeriods =  [TimePeriod]()
    public let start: DateInRegion
    public let end: DateInRegion
    
    private var filters: TimePeriodFilter
    private let tag = "CalendarViewModel"
    private let service: Service

    public init(from model: ServiceViewModel) {
        filters = model.filters
        service = model.selectedService!
        start = model.filters.start
        end = model.filters.end
    }
    
    // MARK: - Actions

    public func getResultsToSend(completion: @escaping (Result<([TimePeriod], URLComponents), Error>) -> Void) {
        let calendar = AppleCalendar()

        filters.min(only: selectedPeriods, tag: tag)
            .subtract(fromSource: calendar, tag: tag) { result in
                let newResults = result.flatMap { filter -> Result<([TimePeriod], URLComponents), Error> in
                    
                    let periods = filter.quantize(unit: self.service.duration, tag: self.tag)
                                        .apply(region: Region.local)

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
