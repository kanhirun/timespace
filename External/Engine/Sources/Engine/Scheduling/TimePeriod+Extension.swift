import Foundation
import SwiftDate

// TODO: TimeIntervals should be designed as half-open intervals

extension TimePeriod: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "TimePeriod<[\(start?.toISO() ?? "∞") - \(end?.toISO() ?? "∞"))>"
    }
}

extension TimePeriod {
    /// Returns a new period representing the overlap between the two
    /// TODO: Handle non-finite cases
    func overlappedPeriod(_ other: TimePeriodProtocol) -> TimePeriodProtocol? {
        guard overlaps(with: other) else {
            return nil
        }
        
        return TimePeriod(start: max(other.start!, start!), end: min(other.end!, end!))
    }
    
    /// Decomposes the time period into smaller ones based on criteria
    internal func _filter(by criteria: (DateInRegion) -> Bool, increment: Calendar.Component) -> [TimePeriod] {
        var res = [TimePeriod]()

        var curr = start!
        let last = end!
        
        // The window representing the valid periods to insert
        var head: DateInRegion? = nil
        var tail: DateInRegion? = nil
        
        while curr < last {
            while curr < last && criteria(curr) {
                let next = curr.dateAtStartOf(increment).dateByAdding(1, increment)

                head = head ?? curr
                tail = last < next  ? last : next
                
                curr = next
            }
            
            if head != nil && tail != nil {
                res.append(TimePeriod(start: head, end: tail))
                head = nil; tail = nil
            }
            
            curr = curr.dateAtStartOf(increment).dateByAdding(1, increment)
        }
        
        return res
    }

}
