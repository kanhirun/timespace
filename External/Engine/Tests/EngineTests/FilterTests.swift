import Quick
import Nimble

import Foundation
import SwiftDate
@testable import Engine

final class FiltersTests: QuickSpec {
    override func spec() {
        
        describe("init()") {
            it("creates a base from start to end") {
                _ = Filters(start: DateInRegion(), end: DateInRegion() + 2.weeks)
            }
        }
        
        describe(".add()") {
            it("pushes new filters in") {
                let subject = Filters(
                    start: DateInRegion("2019-08-12T00:00:00Z")!,
                    end: DateInRegion("2019-08-16T00:00:00Z")!
                )
                
                let lunchPeriod = TimePeriod(start: DateInRegion("2019-08-12T12:00:00Z")!, duration: 1.hours)
                let yogaClass = TimePeriod(start: DateInRegion("2019-08-14T8:00:00Z")!, duration: 2.hours)
                
                subject.min(only: (start: 9, end: 12 + 5), tag: "business-hours")
                       .min(only: .monday, .wednesday, tag: "business-hours")
                       .subtract(with: lunchPeriod, yogaClass, tag: "google-calendar")
                
                let res = subject.apply(region: Region.UTC)
                
                expect(res.count) == 3

                expect(res[0].start?.hour) == 9
                expect(res[0].end?.hour) == 12
                
                expect(res[1].start?.hour) == 1 + 12
                expect(res[1].end?.hour) == 5 + 12
                
                expect(res[2].start?.hour) == 10
                expect(res[2].end?.hour) == 5 + 12
            }
        }
        
        describe("inverse(_:)") {
            it("does the invert for empty") {
                let subject = Filters(
                    start: Date(timeIntervalSince1970: 0),
                    end: Date(timeIntervalSince1970: 10)
                )
                
                let inverted = subject.inversed([aPeriod(0, 10)])
                
                expect(inverted).to(beEmpty())
            }
            
            it("does the invert for start touching") {
                let subject = Filters(
                    start: Date(timeIntervalSince1970: 0),
                    end: Date(timeIntervalSince1970: 10)
                )
                
                let inverted = subject.inversed([aPeriod(0, 5)])
                
                expect(inverted.count) == 1
                expect(inverted.first?.equals(aPeriod(5, 10))).to(beTrue())
            }
            
            it("does the invert for end touching") {
                let subject = Filters(
                    start: Date(timeIntervalSince1970: 0),
                    end: Date(timeIntervalSince1970: 10)
                )
                
                let inverted = subject.inversed([aPeriod(5, 10)])
                
                expect(inverted.first?.equals(aPeriod(0, 5))).to(beTrue())
            }
            
            it("does the invert for enclosing") {
                let subject = Filters(
                    start: Date(timeIntervalSince1970: 0),
                    end: Date(timeIntervalSince1970: 10)
                )
                
                let inverted = subject.inversed([aPeriod(2, 4)])
                
                expect(inverted.first?.equals(aPeriod(0, 2))).to(beTrue())
                expect(inverted.last?.equals(aPeriod(4, 10))).to(beTrue())
            }
            
            it("does the invert for complex") {
                let subject = Filters(
                    start: Date(timeIntervalSince1970: 0),
                    end: Date(timeIntervalSince1970: 10)
                )
                
                let inverted = subject.inversed([aPeriod(2, 4), aPeriod(6, 20)])
                
                expect(inverted.count) == 2
            }
        }
        
        describe(".remove(at:)") {
            it("deletes a filter at some position") {
                let subject = Filters(
                    start: DateInRegion("2019-08-12T00:00:00Z")!,
                    end: DateInRegion("2019-08-16T00:00:00Z")!
                )
                
                subject.min(only: (start: 9, end: 12 + 5), tag: "hours")
                       .min(only: .monday, .wednesday, tag: "weekdays")
                
                expect(subject.apply(region: Region.UTC).count) == 2
                
                subject.remove(withTag: "weekdays")
                
                expect(subject.apply(region: Region.UTC).count) == 4
                
                subject.remove(withTag: "hours")
                
                expect(subject.apply(region: Region.UTC).count) == 1
            }
        }
        
        describe(".quantize(_:unit:)") {
            it("decomposes the time period") {
                let unit = 1.hours
                let periods = [
                    TimePeriod(end: DateInRegion(), duration: 5.hours)
                ]
                
                let res = quantized(periods, unit: unit)
                
                expect(res.count) == 5
                expect(res.allSatisfy { period in
                    period.duration == unit.timeInterval
                }).to(beTrue())
            }

            it("zeros out the time period if unit is larger") {
                let larger = 1.hours
                let smaller = [
                    TimePeriod(end: DateInRegion(), duration: 10.minutes)
                ]
                
                let res = quantized(smaller, unit: larger)
                
                expect(res).to(beEmpty())
            }

            it("decomposes the time period, and disposes the rest") {
                let unit = 1.hours
                let extra = [
                    TimePeriod(end: DateInRegion(), duration: 3.hours + 45.minutes)
                ]
                
                let res = quantized(extra, unit: unit)
                
                expect(res.count) == 3
            }
        }
        
    }
}
