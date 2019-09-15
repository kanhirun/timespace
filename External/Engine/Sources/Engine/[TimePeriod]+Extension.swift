@testable import SwiftDate
import SwiftyJSON
import Foundation

extension TimePeriodCollection {
    
    /// Returns the inverse (i.e. gaps) between the given time periods
    /// ```
    ///   o--o   o-----o  o-o   time periods
    ///
    ///      *---*     *--*      -> returns the gap(s)
    /// ```
    /// - Parameter periods: A list of periods to be inversed
    /// - Returns: A new list of periods
    func inversed(start: DateInRegion, end: DateInRegion) -> [TimePeriod] {
        var curr = start
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
    
    func quantized(unit: DateComponents) -> [TimePeriod] {
        return quantized(unit: unit.timeInterval)
    }
    
    func quantized(unit: TimeInterval) -> [TimePeriod] {
        let res = self.periods
            // Maps the time periods into smaller, unit-sized chunks, if possible
            .compactMap { period -> [TimePeriod] in
                var res = [TimePeriod]()
                
                // if the unit is larger than the period, then drop.
                guard period.duration >= unit else {
                    return res
                }
                
                var i: TimeInterval = 0
                let n: TimeInterval = floor(period.duration / unit)
                var increment = period.start!
                
                while i < n {
                    let chunk = TimePeriod(start: increment, duration: unit)
                    
                    res.append(chunk)
                    
                    increment = increment.addingTimeInterval(unit)
                    i += 1
                }
                
                return res
            }
            // Flattens the results
            .reduce([], +)
        
        return res
    }

}

public extension Array where Element : TimePeriod {
    
    func only(periods: [TimePeriod]) -> [TimePeriod] {
        let arr = self + periods
        
        var i = 0
        var j = i+1
        let n = arr.count
        
        var res = [TimePeriod]()
        
        guard arr.count > 1 else {
            return res
        }
        
        while i < n {
            while j < n {
                if let intersected = arr[i].periodIntersected(arr[j]) {
                    res.append(intersected)
                }
                
                j += 1
            }
            
            i += 1
            j = i+1
        }
        
        return res
    }
    
    func encloses(with period: TimePeriod) -> Bool {
        return periodsShallowMerged().contains { $0.encloses(with: period) }
    }

    /// Returns a list of `TimePeriod` that is rounded, if possible
    func periodsRounded(_ mode: RoundDateMode, within availability: [TimePeriod]) -> [TimePeriod] {
        let res = self.compactMap { (period: TimePeriod) -> TimePeriod? in
            let suggestion = period.periodRounded(mode)

            if availability.encloses(with: suggestion) {
                return suggestion
            } else {
                return nil
            }
        }

        return res
    }
    
    // TODO: recursive merging? or better to say flatten?
    func periodsShallowMerged() -> [TimePeriod] {
        var i = 0
        var j = i+1
        let arr = self
        let n = arr.count
        var isMerged = false

        var res = [TimePeriod]()

        while i < n {
            while j < n {
                if let merged = arr[i].periodMerged(arr[j]) {
                    res.append(merged as! TimePeriod)
                    isMerged = true
                }
                
                j += 1
            }
            
            if !isMerged {
                res.append(arr[i])
                isMerged = false
            }

            i += 1
            j = i+1
        }
        
        return res
    }

    func only(fromHours hours: [(start: Int, end: Int)]) -> [TimePeriod] {
        func matchesHourlyPeriods(_ curr: DateInRegion) -> Bool {
            return hours.first(where: { start, end in start <= curr.hour && curr.hour < end }) != nil
        }
        
        return flatMap { period -> [TimePeriod] in
            period._filter(by: matchesHourlyPeriods, increment: .hour)
        }
    }
    
    func only(weekdays: [WeekDay]) -> [TimePeriod] {
        func matchesWeekdays(_ date: DateInRegion) -> Bool {
            return weekdays.contains(WeekDay(rawValue: date.weekday)!)
        }
        
        return flatMap { period -> [TimePeriod] in
            period._filter(by: matchesWeekdays(_:), increment: .day)
        }
    }
}
