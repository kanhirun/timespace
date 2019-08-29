import Quick
import Nimble

import Foundation
import SwiftDate

@testable import Engine

final class TimePeriodArrayTests: QuickSpec {
    override func spec() {

        describe(".periodIntersecteds()") {
            it("returns nil when no there is no overlapping") {
                let before = aPeriod(1, 5)
                let touchingStart = aPeriod(15, 20)
                let after = aPeriod(20, 30)
                let touchingEnd = aPeriod(1, 10) // 10 is touching
                let subject = aPeriod(10, 15)
                
                expect(subject.periodIntersected(before)).to(beNil())
                expect(subject.periodIntersected(touchingEnd)).to(beNil())
                expect(touchingEnd.periodIntersected(subject)).to(beNil())  // order doesn't matter
                expect(subject.periodIntersected(touchingStart)).to(beNil())
                expect(after.periodIntersected(subject)).to(beNil())
            }
            
            it("returns the same period when exact") {
                let subject = aPeriod(1, 5)
                let exact = subject
                
                let results = subject.periodIntersected(exact)!
                
                expect(results.start!.timeIntervalSince1970) == 1
                expect(results.end!.timeIntervalSince1970) == 5
            }
            
            it("returns the shorter period") {
                let short = aPeriod(1, 5)
                let long = aPeriod(1, 10)
                
                let results = short.periodIntersected(long)!
                
                expect(results.start!.timeIntervalSince1970) == 1
                expect(results.end!.timeIntervalSince1970) == 5
            }
            
            it("returns the period enclosed by the bigger one") {
                let big = aPeriod(1, 10)
                let enclosed = aPeriod(2, 4)
                
                let results = big.periodIntersected(enclosed)!
                
                expect(results.start!.timeIntervalSince1970) == 2
                expect(results.end!.timeIntervalSince1970) == 4
            }
        }
        
        describe("toJSON()") {
            it("converts to JSON") {
                let subject = TimePeriod(
                    start: DateInRegion("2019-08-01T00:00:00Z")!,
                    end: DateInRegion("2019-09-22T22:22:22Z")!
                )
                
                let json = subject.toJSON()
                
                expect(json["start"].stringValue) == "2019-08-01T00:00:00Z"
                expect(json["end"].stringValue) == "2019-09-22T22:22:22Z"
            }
        }

        describe(".periodRounded(_:)") {
            it("shifts the time period to the rounded value") {
                let subject = TimePeriod(
                    start: DateInRegion("2019-08-01T00:15:00Z")!,
                    end: DateInRegion("2019-08-01T1:30:00Z")!
                )
                
                let rounded = subject.periodRounded(.toCeil30Mins)

                expect(rounded.start!.dateComponents.hour) == 0
                expect(rounded.start!.dateComponents.minute) == 30
                expect(subject.duration) == rounded.duration
            }
            
            it("shifts the time period to the floored value") {
                let subject = TimePeriod(
                    start: DateInRegion("2019-08-01T10:18:00Z")!,
                    end: DateInRegion("2019-08-01T1:30:00Z")!
                )
                
                let rounded = subject.periodRounded(.toFloorMins(15))

                expect(rounded.start!.dateComponents.hour) == 10
                expect(rounded.start!.dateComponents.minute) == 15
            }
            
            it("does not shift when no rounding occurs") {
                let subject = TimePeriod(
                    start: DateInRegion("2019-08-01T10:00:00Z")!,
                    end: DateInRegion("2019-08-01T1:30:00Z")!
                )
                
                let rounded = subject.periodRounded(.toFloorMins(60))
                
                expect(rounded.start!.dateComponents.hour) == 10
                expect(rounded.start!.dateComponents.minute) == 0
            }
        }
    }

}
