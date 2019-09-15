import Quick
import Nimble

import Foundation
import SwiftDate
@testable import Engine

final class TimePeriodCollectionTests: QuickSpec {
    override func spec() {
        describe("inversed(_:)") {
            it("returns empty when input has no gaps") {
                /// ```
                ///    *        *   1. the edges, with
                ///    o----o       2. periods w/ no gaps
                ///         o---o
                ///
                ///        []       -> returns empty
                /// ```
                let subject = TimePeriodCollection([aPeriod(0, 10)])
                
                let inverted = subject.inversed(start: DateInRegion(Date(timeIntervalSince1970: 0)),
                                                end: DateInRegion(Date(timeIntervalSince1970: 10)))
                
                expect(inverted).to(beEmpty())
            }
            
            it("can return gaps along with the right edge") {
                /// ```
                ///    *        *    1. the edges, with
                ///    o---o         2. a period
                ///
                ///        *----*    -> returns the gap with edge
                /// ```
                let subject = TimePeriodCollection([aPeriod(0, 5)])
                
                let inverted = subject.inversed(start: DateInRegion(Date(timeIntervalSince1970: 0)),
                                                end: DateInRegion(Date(timeIntervalSince1970: 10)))
                
                expect(inverted.count) == 1
                expect(inverted.first?.equals(aPeriod(5, 10))).to(beTrue())
            }
            
            it("can return gaps with the left edge") {
                /// ```
                ///    *        *    1. the edges, with
                ///        o----o    2. a period
                ///
                ///    *---*         -> returns the gap with edge
                /// ```
                let subject = TimePeriodCollection([aPeriod(5, 10)])
                
                let inverted = subject.inversed(start: DateInRegion(Date(timeIntervalSince1970: 0)),
                                                end: DateInRegion(Date(timeIntervalSince1970: 10)))
                
                expect(inverted.first) == aPeriod(0, 5)
            }
            
            it("returns two gaps when period is enclosed") {
                /// ```
                ///    *            *    1. the edges, with
                ///         o---o        2. a period
                ///
                ///    *---*    *---*    -> returns gaps
                /// ```
                let subject = TimePeriodCollection([aPeriod(2, 4)])
                
                let inverted = subject.inversed(start: DateInRegion(Date(timeIntervalSince1970: 0)),
                                                end: DateInRegion(Date(timeIntervalSince1970: 10)))

                expect(inverted.first) == aPeriod(0, 2)
                expect(inverted.last) == aPeriod(4, 10)
            }
            
            it("returns the gaps for complex cases") {
                let subject = TimePeriodCollection([aPeriod(2, 4), aPeriod(5, 20)])
                
                let inverted = subject.inversed(start: DateInRegion(Date(timeIntervalSince1970: 0)),
                                                end: DateInRegion(Date(timeIntervalSince1970: 10)))
                
                expect(inverted.count) == 2
            }
        }

    }
}
