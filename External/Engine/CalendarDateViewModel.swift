import Foundation
import SwiftDate
import struct CoreGraphics.CGFloat

public class CalendarDateViewModel {
    
    public enum ViewState {
        case selected
        case available
        case unavailable
    }
    
    public enum BusyLevel {
        case high
        case medium
        case low
        case free
    }
    
    /// The text shown on the view
    /// e.g., `Aug 1` or `1`.
    public var dateText: String {
        if date.day == 1 {
            return "\(date.monthName(.short))\n\(date.day)"
        } else {
            return "\(date.day)"
        }
    }
    
    /// Indicates to users how busy that day is
    ///
    /// - Note: Values are bucketed into 4 distinct levels
    public var busyLevel: BusyLevel {
        switch _busyLevel {
        case _ where _busyLevel >= 0.75:
            return .high
        case _ where _busyLevel >= 0.50:
            return .medium
        case _ where _busyLevel > 0.0:
            return .low
        default:
            return .free
            
        }
    }
    
    public private(set) var viewState: ViewState = .unavailable
    private let _busyLevel: CGFloat
    private let period: TimePeriod
    private let date: DateInRegion
    private let availability: TimePeriodCollection
    
    public init(localDate: Date, occupiedTimes: TimePeriodCollection, availableTimes: TimePeriodCollection) {

        // move me
        func compute(t1: TimePeriodCollection, t2: TimePeriodCollection) -> CGFloat {
            let lhs = t1.reduce(0.0) { res, curr -> TimeInterval in
                res + curr.duration
            }
            let rhs = t2.reduce(0.0) { res, curr -> TimeInterval in
                res + curr.duration
            }
            
            return CGFloat(lhs / rhs)
        }

        let start = localDate
        self._busyLevel = compute(t1: occupiedTimes, t2: availableTimes)
        self.period = TimePeriod(startDate: start, endDate: start.dateByAdding(1, .day).date)
        self.date = DateInRegion(start)
        self.availability = availableTimes
        deselect()
    }
    
    func isToday() -> Bool {
        return date.isToday
    }
    
    public func select() {
        viewState = .selected
    }
    
    public func deselect() {
        let availableTimes = availability.periodsInside(period: period) // wtf
        
        if availableTimes.count > 0 && !date.isInPast {
            viewState = .available
        } else {
            viewState = .unavailable
        }
    }
}
