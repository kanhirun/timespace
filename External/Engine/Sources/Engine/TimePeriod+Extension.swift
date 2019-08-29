import Foundation
import SwiftDate


extension TimePeriodProtocol {
    /// Returns `Bool` on whether one encloses the other
    func encloses(with period: TimePeriodProtocol) -> Bool {
        switch relation(to: period) {
        case .enclosingStartTouching: fallthrough
        case .enclosing: fallthrough
        case .enclosingEndTouching: fallthrough
        case .exactMatch:
            return true
        default:
            return false
        }
    }
}

extension TimePeriod {
    
    /// Returns the intersected `TimePeriod`
    /// ```
    ///     o-------o
    ///         o------o
    ///         o---o     <- result
    /// ```
    /// - Parameter other: the given period
    /// - Returns: An overlapping period or `nil` otherwise
    func periodIntersected(_ otherPeriod: TimePeriodProtocol) -> TimePeriodProtocol? {
        guard overlaps(with: otherPeriod) else { return nil }

        return TimePeriod(start: max(otherPeriod.start!, start!), end: min(otherPeriod.end!, end!))
    }
    
    /// Returns a merged `TimePeriod`
    /// ```
    ///     o-------o
    ///         o------o
    ///     o----------o   <- result
    /// ```
    /// - Parameter other: the given period
    /// - Returns: A merged period or `nil` otherwise
    func periodMerged(_ otherPeriod: TimePeriodProtocol) -> TimePeriodProtocol? {
        guard intersects(with: otherPeriod) else { return nil }

        return TimePeriod(start: min(otherPeriod.start!, start!), end: max(otherPeriod.end!, end!))
    }
    
    /// Returns a new `TimePeriod` that is **shifted** to the rounded value
    /// ```
    ///     o--*----o
    ///        o-------o  <- result (shifted)
    /// ```
    /// - Parameter mode: an enum describing how to round the period
    /// - Returns: A new `TimePeriod` that is shifted to the rounded value
    func periodRounded(_ mode: RoundDateMode) -> TimePeriod {
        guard hasFiniteRange else {
            fatalError("Cannot round infinite time periods.")
        }

        let roundedStart = start!.dateRoundedAt(mode)
        let dt = roundedStart.timeIntervalSince(start!)
        
        return shifted(by: dt)
    }
    
    /// Splits `TimePeriod` into smaller ones
    /// ```
    ///     o------------o
    ///
    ///     o---o  o-----o   <- result (stays within bounds)
    /// ```
    /// - Parameters:
    ///   - criteria: A closure that determines whether to decompose this date, or not
    ///   - increment: Tells the function when to check
    /// - Returns: A list of time periods that are smaller in range
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
