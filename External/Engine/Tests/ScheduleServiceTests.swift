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
        
        describe("render(region:at:)") {
            it("returns nil if tag doesn't exist") {}
            it("can return the top layer") {}
            it("can return the bottom layer") {}
            it("can return the middle layers") {
                let subject = ScheduleService(start: Date(timeIntervalSince1970: 0),
                                              end: Date(timeIntervalSince1970: 10))
                
                subject.min(only: aPeriod(2, 6), tag: "1")
                subject.min(only: aPeriod(4, 8), tag: "2")
                subject.min(only: aPeriod(6, 6), tag: "3")
                
                let res = subject.render(region: Region.UTC, at: "2")
                                 .compactMap { $0 } as! [TimePeriod]

                expect(res) == [aPeriod(4, 6)]
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
