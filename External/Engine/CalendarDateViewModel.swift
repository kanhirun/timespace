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
        switch rand {
        case _ where rand >= 0.75:
            return .high
        case _ where rand >= 0.50:
            return .medium
        case _ where rand >= 0.25:
            return .low
        default:
            return .free
            
        }
    }
    
    public private(set) var viewState: ViewState = .unavailable
    private let rand: CGFloat
    private let period: TimePeriod
    private let date: DateInRegion
    private let availability: TimePeriodCollection
    
    public init(localDate: Date, availability: TimePeriodCollection) {
        let start = localDate
        self.rand = CGFloat.random(in: 0.0...1.0)
        self.period = TimePeriod(startDate: start, endDate: start.dateByAdding(1, .day).date)
        self.date = DateInRegion(start)
        self.availability = availability
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
