import Quick
import Nimble

import Foundation
import SwiftDate

@testable import Engine

final class TimePeriodArrayTests: QuickSpec {
    override func spec() {

        describe(".periodIntersected(_:)") {
            it("returns the enclosed period") {
                /// ```
                ///      o-----------o
                ///         o-----o       is enclosed
                ///
                ///         *-----*       -> returns enclosed period
                /// ```
                let enclosing = aPeriod(1, 10)
                let enclosed  = aPeriod(2, 4)
                
                let results = enclosing.periodIntersected(enclosed)!
                
                expect(results) == enclosed
            }
            
            it("returns the shorter period") {
                /// ```
                ///     o---*           is shorter
                ///     *-----------o
                ///
                ///     *---*           -> returns shorter period
                /// ```
                let short = aPeriod(1, 5)
                let long  = aPeriod(1, 10)

                let results = short.periodIntersected(long)!

                expect(results) == short
            }
            
            it("returns nil when nothing intersects") {
                /// ```
                ///  o----o                         before
                ///           *-----*
                ///       o---o                     touching-start
                ///                 o---o           touching-end
                ///                        o---o    after
                ///
                ///                                 -> returns `nil`
                /// ```
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
            
            it("returns the identical period when exact") {
                /// ```
                ///     o--------o
                ///     o--------o
                ///
                ///     *--------*   -> returns identical period
                /// ```
                let subject = aPeriod(1, 5)
                let aCopy   = aPeriod(1, 5)
                
                let exactMatch = subject.periodIntersected(aCopy)!
                
                expect(exactMatch) == subject
            }
        }

        describe(".periodRounded(_:)") {
            it("shifts the period by rounding up") {
                /// ```
                ///     o--*----o  *     will be rounded up
                ///
                ///        *-------*  -> returns shifted
                /// ```
                let subject = TimePeriod(
                    start: DateInRegion("2019-08-01T00:15:00Z")!,
                    end: DateInRegion.randomDate()
                )
                
                let rounded = subject.periodRounded(.toCeil30Mins)

                expect(rounded.start?.dateComponents.hour) == 0
                expect(rounded.start?.dateComponents.minute) == 30
                expect(subject.duration) == rounded.duration
            }
            
            it("shifts the period by rounding down") {
                /// ```
                ///     *  o----*--o     will be rounded up
                ///
                ///     *-------*        -> returns shifted
                /// ```
                let subject = TimePeriod(
                    start: DateInRegion("2019-08-01T10:18:00Z")!,
                    end: DateInRegion("2019-08-01T1:30:00Z")!
                )
                
                let rounded = subject.periodRounded(.toFloorMins(15))

                expect(rounded.start!.dateComponents.hour) == 10
                expect(rounded.start!.dateComponents.minute) == 15
            }
            
            it("doesn't shift if no rounding") {
                /// ```
                ///     o-------o     no rounding
                ///
                ///     *-------*     -> returns identical
                /// ```
                let subject = TimePeriod(
                    start: DateInRegion("2019-08-01T10:00:00Z")!,
                    end: DateInRegion("2019-08-01T1:30:00Z")!
                )
                
                let rounded = subject.periodRounded(.toFloorMins(60))

                expect(rounded) == subject
            }
        }
        
        describe("toJSON()") {
            it("converts to JSON") {
                let subject = TimePeriod(
                    start: DateInRegion("2019-08-01T00:00:00Z")!,
                    end: DateInRegion("2019-09-22T22:22:22Z")!
                )
                
                let json = subject.toJSON()
                
                expect(json["start"].string) == "2019-08-01T00:00:00Z"
                expect(json["end"].string) == "2019-09-22T22:22:22Z"
            }
        }
    }

}
