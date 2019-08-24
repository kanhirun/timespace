import Foundation
import SwiftDate

func quantized(_ periods: [TimePeriod], unit: DateComponents) -> [TimePeriod] {
    let res = periods
        // Maps the time periods into smaller, unit-sized chunks, if possible
        .compactMap { period -> [TimePeriod] in
            var res = [TimePeriod]()

            // if the unit is larger than the period, then drop.
            guard period.duration >= unit.timeInterval else {
                return res
            }

            var i: TimeInterval = 0
            let n: TimeInterval = floor(period.duration / unit.timeInterval)
            var increment = period.start!

            while i < n {
                let chunk = TimePeriod(start: increment, duration: unit)

                res.append(chunk)

                increment = increment.addingTimeInterval(unit.timeInterval)
                i += 1
            }

            return res
        }
        // Flattens the results
        .reduce([], +)

    return res
}

public final class TimePeriodFilter {
    
    public let start: DateInRegion
    public let end: DateInRegion
    
    typealias Filter = (tag: String, contents: [TimePeriod])

    /// Tracks the operations applied
    private var stack = [Filter]()

    /// Represents the absolute lower and upper bounds of all periods
    private let window: [TimePeriod]
    
    // MARK: - Create
    
    public convenience init(start: DateInRegion, duration: DateComponents) {
        self.init(start: start, end: start + duration)
    }
    
    convenience public init(start: Date, end: Date) {
        self.init(start: DateInRegion(start, region: start.region), end: DateInRegion(end, region: end.region))
    }
    
    public init(start: DateInRegion, end: DateInRegion) {
        self.start = start
        self.end = end
        self.window = [TimePeriod(start: start, end: end)]
        let copy  = [TimePeriod(start: start, end: end)]

        stack.append((tag: "base", contents: copy))
    }
    
    // MARK: - Reduce
    
    public func apply(region: Region) -> [TimePeriod] {
        return stack.map { $0.contents }
                    .reduce(window) { res, next  in res.only(periods: next) }
                    .map { TimePeriod(start: $0.start?.convertTo(region: region), end: $0.end?.convertTo(region: region)) }
    }
    
    // MARK: - Filter
    
    @discardableResult
    public func min(only hours: (start: Int, end: Int)..., tag: String) -> TimePeriodFilter {
        let filtered = window.only(fromHours: hours)
        stack.append( (tag: tag, contents: filtered) )
        return self
    }
    
    @discardableResult
    public func min(only weekdays: WeekDay..., tag: String) -> TimePeriodFilter {
        let filtered = window.only(weekdays: weekdays)
        stack.append( (tag: tag, contents: filtered) )
        return self
    }
    
    @discardableResult
    public func min(only periods: TimePeriod..., tag: String) -> TimePeriodFilter {
        return self.min(only: periods, tag: tag)
    }
    
    @discardableResult
    public func min(only periods: [TimePeriod], tag: String) -> TimePeriodFilter {
        let filtered = window.only(periods: periods)
        stack.append( (tag: tag, contents: filtered) )
        return self
    }
    
    @discardableResult
    public func subtract(with periods: [TimePeriod], tag: String) -> TimePeriodFilter {
        let input = inversed(periods)
        let filtered = window.only(periods: input)

        stack.append( (tag: tag, contents: filtered) )
        
        return self
    }
    
    @discardableResult
    public func subtract(with periods: TimePeriod..., tag: String) -> TimePeriodFilter {
        return subtract(with: periods, tag: tag)
    }
    
    // MARK: - Filter - Calendar

    public func subtract(fromSource source: CalendarDataSource,
                         tag: String,
                         completion: @escaping (Result<(TimePeriodFilter), Error>) -> Void) {
        let start = window.first!.start!
        let end = window.first!.end!
        
        source.timePeriods(from: start, until: end,
                           onSuccess: { results in
                                self.subtract(with: results, tag: tag)
                                completion(.success(self))
                            },
                           onFailure: { err in
                                completion(.failure(err))
                           })
    }
    
    /// MARK: - Transform
    
    public func quantize(unit: DateComponents, tag: String) -> TimePeriodFilter {
        let results = quantized(apply(region: .UTC), unit: unit)

        stack.append( (tag: tag, contents: results) )
        
        return self
    }
    
    /// MARK: - Delete
    
    public func remove(withTag target: String) {
        stack.removeAll { filter -> Bool in filter.tag == target }
    }
    
    /// MARK: - Helpers
    func inversed(_ periods: [TimePeriod]) -> [TimePeriod] {
        var curr = window.first!.start!
        let end = window.first!.end!
        var iter = periods.makeIterator()
        var res = [TimePeriod]()

        while curr < end {
            let period = iter.next() ?? TimePeriod(start: end, end: end)
            
            if curr < period.start! {
                res.append(TimePeriod(start: curr, end: period.start!))
            }

            curr = period.end!
        }
        
        return res
    }
}
