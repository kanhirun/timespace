import Foundation
import SwiftDate


public final class Filters {
    
    typealias Filter = (tag: String, contents: [TimePeriod])
    
    private var stack = [Filter]()
    fileprivate let base: [TimePeriod]
    
    // MARK: - Initializers
    
    public convenience init(start: DateInRegion, duration: DateComponents) {
        self.init(start: start, end: start + duration)
    }
    
    convenience public init(start: Date, end: Date) {
        self.init(start: DateInRegion(start, region: start.region), end: DateInRegion(end, region: end.region))
    }
    
    public init(start: DateInRegion, end: DateInRegion) {
        self.base = [TimePeriod(start: start, end: end)]
        let copy  = [TimePeriod(start: start, end: end)]

        stack.append((tag: "base", contents: copy))
    }
    
    // MARK: - Reduce
    
    public func apply(region: Region) -> [TimePeriod] {
        return stack.map { $0.contents }
                    .reduce(base) { res, next  in res.only(periods: next) }
                    .map { TimePeriod(start: $0.start?.convertTo(region: region), end: $0.end?.convertTo(region: region)) }
    }
    
    // MARK: - Filter
    
    @discardableResult
    public func min(only hours: (start: Int, end: Int)..., tag: String) -> Filters {
        let filtered = base.only(fromHours: hours)
        stack.append( (tag: tag, contents: filtered) )
        return self
    }
    
    @discardableResult
    public func min(only weekdays: WeekDay..., tag: String) -> Filters {
        let filtered = base.only(weekdays: weekdays)
        stack.append( (tag: tag, contents: filtered) )
        return self
    }
    
    @discardableResult
    public func min(only periods: TimePeriod..., tag: String) -> Filters {
        let filtered = base.only(periods: periods)
        stack.append( (tag: tag, contents: filtered) )
        return self
    }
    
    @discardableResult
    public func subtract(with periods: [TimePeriod], tag: String) -> Filters {
        let input = inversed(periods)
        let filtered = base.only(periods: input)

        stack.append( (tag: tag, contents: filtered) )
        
        return self
    }
    
    @discardableResult
    public func subtract(with periods: TimePeriod..., tag: String) -> Filters {
        return subtract(with: periods, tag: tag)
    }
    
    // MARK: - Filter - Calendar

    public func subtract(fromSource source: CalendarDataSource,
                         tag: String,
                         onSuccess: (() -> Void)?,
                         onFailure: ((Error) -> Void)?) {
        let start = base.first!.start!
        let end = base.first!.end!
        
        source.timePeriods(from: start, until: end,
                           onSuccess: { results in
                                self.subtract(with: results, tag: tag)
                                onSuccess?()
                            },
                           onFailure: { err in
                                onFailure?(err)
                           })
    }
    
    // MARK: - Transform
    
    func inversed(_ periods: [TimePeriod]) -> [TimePeriod] {
        var curr = base.first!.start!
        let end = base.first!.end!
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
    
    // MARK: - Delete

    public func remove(withTag target: String) {
        stack.removeAll { filter -> Bool in filter.tag == target }
    }
}
