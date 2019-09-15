import Quick
import Nimble

import SwiftDate
import Foundation
@testable import Engine

final class CalendarDateViewModelTests: QuickSpec {
    override func spec() {
        describe("busyLevel") {
            it("returns high when all occupied") {
                let subject = CalendarDateViewModel(
                    localDate: Date(),
                    occupiedTimes: TimePeriodCollection([aPeriod(0, 10)]),
                    availableTimes: TimePeriodCollection([aPeriod(0, 10)])
                )
                
                expect(subject.busyLevel) == .high
            }
            
            it("returns medium when some occupied") {
                let subject = CalendarDateViewModel(
                    localDate: Date(),
                    occupiedTimes: TimePeriodCollection([aPeriod(0, 5)]),
                    availableTimes: TimePeriodCollection([aPeriod(0, 10)])
                )
                
                expect(subject.busyLevel) == .medium
            }
            
            it("returns low when mostly available") {
                let subject = CalendarDateViewModel(
                    localDate: Date(),
                    occupiedTimes: TimePeriodCollection([aPeriod(0, 1)]),
                    availableTimes: TimePeriodCollection([aPeriod(0, 10)])
                )
                
                expect(subject.busyLevel) == .low
            }
            
            
            it("returns free when all available") {
                let subject = CalendarDateViewModel(
                    localDate: Date(),
                    occupiedTimes: TimePeriodCollection([]),
                    availableTimes: TimePeriodCollection([aPeriod(0, 10)])
                )
                
                expect(subject.busyLevel) == .free
            }
        }
    }
}
