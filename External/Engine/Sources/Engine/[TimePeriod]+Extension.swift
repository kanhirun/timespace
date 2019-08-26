import SwiftDate
import SwiftyJSON
import Foundation

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
                if let overlap = arr[i].overlappedPeriod(arr[j]) {
                    res.append(overlap as! TimePeriod)
                }
                
                j += 1
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
