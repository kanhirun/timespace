import Quick
import Nimble

import Foundation
import SwiftDate
@testable import Engine

final class ScheduleServiceTests: QuickSpec {
    override func spec() {
         context("methods") {
            it("appends to a stack") {
                let subject = ScheduleService(
                    start: DateInRegion("2019-08-12T00:00:00Z")!,
                    end: DateInRegion("2019-08-16T00:00:00Z")!
                )
                
                let lunchPeriod = TimePeriod(start: DateInRegion("2019-08-12T12:00:00Z")!, duration: 1.hours)
                let yogaClass = TimePeriod(start: DateInRegion("2019-08-14T8:00:00Z")!, duration: 2.hours)
                
                subject.min(only: (start: 9, end: 12 + 5), tag: "business-hours")
                       .min(only: .monday, .wednesday, tag: "business-hours")
                       .subtract(with: lunchPeriod, yogaClass, tag: "google-calendar")
                
                let res = subject.render(region: Region.UTC).compactMap { $0 }
                
                expect(res.count) == 3
                
                expect(res[0].start?.hour) == 9
                expect(res[0].end?.hour) == 12
                
                expect(res[1].start?.hour) == 1 + 12
                expect(res[1].end?.hour) == 5 + 12
                
                expect(res[2].start?.hour) == 10
                expect(res[2].end?.hour) == 5 + 12
            }
        }
        
        describe("inversed(_:)") {
            it("returns empty when input has no gaps") {
                /// ```
                ///    *        *   1. the edges, with
                ///    o----o       2. periods w/ no gaps
                ///         o---o
                ///
                ///        []       -> returns empty
                /// ```
                let subject = ScheduleService(
                    start: Date(timeIntervalSince1970: 0),
                    end: Date(timeIntervalSince1970: 10)
                )
                
                let inverted = subject.inversed([aPeriod(0, 10)])
                
                expect(inverted).to(beEmpty())
            }
            
            it("can return gaps along with the right edge") {
                /// ```
                ///    *        *    1. the edges, with
                ///    o---o         2. a period
                ///
                ///        *----*    -> returns the gap with edge
                /// ```
                let subject = ScheduleService(
                    start: Date(timeIntervalSince1970: 0),
                    end: Date(timeIntervalSince1970: 10)
                )
                
                let inverted = subject.inversed([aPeriod(0, 5)])
                
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
                let subject = ScheduleService(
                    start: Date(timeIntervalSince1970: 0),
                    end: Date(timeIntervalSince1970: 10)
                )
                
                let inverted = subject.inversed([aPeriod(5, 10)])
                
                expect(inverted.first?.equals(aPeriod(0, 5))).to(beTrue())
            }
            
            it("does the invert for enclosing") {
                let subject = ScheduleService(
                    start: Date(timeIntervalSince1970: 0),
                    end: Date(timeIntervalSince1970: 10)
                )
                
                let inverted = subject.inversed([aPeriod(2, 4)])
                
                expect(inverted.first?.equals(aPeriod(0, 2))).to(beTrue())
                expect(inverted.last?.equals(aPeriod(4, 10))).to(beTrue())
            }
            
            it("does the invert for complex") {
                let subject = ScheduleService(
                    start: Date(timeIntervalSince1970: 0),
                    end: Date(timeIntervalSince1970: 10)
                )
                
                let inverted = subject.inversed([aPeriod(2, 4), aPeriod(6, 20)])
                
                expect(inverted.count) == 2
            }
        }
        
        describe(".remove(at:)") {
            it("deletes a filter at some position") {
                let subject = ScheduleService(
                    start: DateInRegion("2019-08-12T00:00:00Z")!,
                    end: DateInRegion("2019-08-16T00:00:00Z")!
                )
                
                subject.min(only: (start: 9, end: 12 + 5), tag: "hours")
                       .min(only: .monday, .wednesday, tag: "weekdays")
                
                expect(subject.render(region: Region.UTC).count) == 2
                
                subject.remove(withTag: "weekdays")
                
                expect(subject.render(region: Region.UTC).count) == 4
                
                subject.remove(withTag: "hours")
                
                expect(subject.render(region: Region.UTC).count) == 1
            }
        }
        
        describe(".quantize(_:unit:)") {
            it("decomposes the time period") {
                let unit = 1.hours
                let periods = TimePeriodCollection([
                    TimePeriod(end: DateInRegion(), duration: 5.hours)
                ])
                
                let res = periods.quantized(unit: unit)
                
                expect(res.count) == 5
                expect(res.allSatisfy { period in
                    period.duration == unit.timeInterval
                }).to(beTrue())
            }

            it("zeros out the time period if unit is larger") {
                let larger = 1.hours
                let smaller = TimePeriodCollection([
                    TimePeriod(end: DateInRegion(), duration: 10.minutes)
                ])
                
                let res = smaller.quantized(unit: larger)
                
                expect(res).to(beEmpty())
            }

            it("decomposes the time period, and disposes the rest") {
                let unit = 1.hours
                let extra = TimePeriodCollection([
                    TimePeriod(end: DateInRegion(), duration: 3.hours + 45.minutes)
                ])
                
                let res = extra.quantized(unit: unit)
                
                expect(res.count) == 3
            }
        }
        
    }
}
