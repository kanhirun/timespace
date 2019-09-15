import Foundation
import SwiftDate

public final class ScheduleService {
    
    typealias Layer = (tag: String, contents: [TimePeriod])
    
    public let start: DateInRegion
    public let end: DateInRegion

    /// Tracks the operations applied
    private var layers = [Layer]()

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

        layers.append((tag: "base", contents: copy))
    }
    
    // MARK: - Reduce
    
    public func render(region: Region) -> TimePeriodCollection {
        let arr = layers.map { $0.contents }
                        .reduce(window) { res, next  in res.only(periods: next) }
                        .map { TimePeriod(start: $0.start?.convertTo(region: region), end: $0.end?.convertTo(region: region)) }
        
        return TimePeriodCollection(arr)
    }
    
    
    /// Renders the stack partially or completely based on tag
    public func render(region: Region, at tag: String) -> TimePeriodCollection {
        var res = window

        for layer in layers {
            res = res.only(periods: layer.contents)

            if tag == layer.tag {
                break
            }
        }
        
        let arr = res.map { period in
                return TimePeriod(
                    start: period.start?.convertTo(region: region),
                    end: period.end?.convertTo(region: region)
                )
            }

        return TimePeriodCollection(arr)
    }
    
    // MARK: - Filter
    
    @discardableResult
    public func min(only hours: (start: Int, end: Int)..., tag: String) -> Self {
        let filtered = window.only(fromHours: hours)
        layers.append( (tag: tag, contents: filtered) )
        return self
    }
    
    @discardableResult
    public func min(only weekdays: WeekDay..., tag: String) -> Self {
        let filtered = window.only(weekdays: weekdays)
        layers.append( (tag: tag, contents: filtered) )
        return self
    }
    
    @discardableResult
    public func min(only periods: TimePeriod..., tag: String) -> Self {
        return self.min(only: periods, tag: tag)
    }
    
    @discardableResult
    public func min(only periods: [TimePeriod], tag: String) -> Self {
        let filtered = window.only(periods: periods)
        layers.append( (tag: tag, contents: filtered) )
        return self
    }
    
    @discardableResult
    public func subtract(with periods: [TimePeriod], tag: String) -> Self {
        let input = inversed(periods)
        let filtered = window.only(periods: input)

        layers.append( (tag: tag, contents: filtered) )
        
        return self
    }
    
    @discardableResult
    public func subtract(with periods: TimePeriod..., tag: String) -> Self {
        return subtract(with: periods, tag: tag)
    }
    
    // MARK: - Filter - Calendar

    @discardableResult
    public func subtract(fromSource source: CalendarDataSource, tag: String) -> Self {
        let start = window.first!.start!
        let end = window.first!.end!
        
        return self.subtract(with: source.timePeriods(from: start, until: end), tag: tag)
    }
    
    /// MARK: - Transform
    
    @discardableResult
    public func quantize(unit: TimeInterval, tag: String) -> Self {
        let results = render(region: .UTC).quantized(unit: unit)
        let rounded = results.periodsRounded(.toCeilMins(60), within: results).periodsShallowMerged()

        layers.append( (tag: tag, contents: rounded) )
        
        return self
    }
    
    /// MARK: - Delete
    
    public func remove(withTag target: String) {
        layers.removeAll { filter -> Bool in filter.tag == target }
    }
    
    /// MARK: - Helpers
    
    /// Returns the inverse (i.e. gaps) between the given time periods
    /// ```
    ///   o--o   o-----o  o-o   time periods
    ///
    ///      *---*     *--*      -> returns the gap(s)
    /// ```
    /// - Parameter periods: A list of periods to be inversed
    /// - Returns: A new list of periods
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
