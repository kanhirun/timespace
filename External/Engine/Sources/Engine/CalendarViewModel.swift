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

    public func getResultsToSend(completion: @escaping (Result<[TimePeriod], Error>) -> Void) {
        let calendar = AppleCalendar()

        filters.min(only: selectedPeriods, tag: tag)
            .subtract(fromSource: calendar, tag: tag) { result in
                let newResults = result.flatMap { filter -> Result<[TimePeriod], Error> in
                    Result { filter.quantize(unit: self.service.duration, tag: self.tag)
                                   .apply(region: Region.local) }
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
    
    // MARK: - Helpers
    
    public func serviceAsQueryItem() -> URLQueryItem {
        return URLQueryItem(name: "service", value: service.toJSON().rawString())
    }
}
