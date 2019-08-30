import Quick
import Nimble

import Foundation
import SwiftDate
import SwiftyJSON

@testable import Engine

final class TimePeriodTests: QuickSpec {
    override func spec() {
         
        var subject: [TimePeriod]!
        
        describe(".only(periods:)") {
            it("can filter with other periods") {
                let subject = [aPeriod(0, 10), aPeriod(20, 30)]
                
                let res = subject.only(periods: [aPeriod(5, 15), aPeriod(20, 30)])

                expect(res.count) == 2
                expect(res.first?.start) == aPeriod(5, 10).start
                expect(res.first?.end) == aPeriod(5, 10).end
                expect(res.last?.start) == aPeriod(20, 30).start
                expect(res.last?.end) == aPeriod(20, 30).end
            }
        }
        
        describe("periodMerged") {
            it("returns nil if it doesn't merge") {
                let noMerge = aPeriod(0, 5).periodMerged(aPeriod(10, 20))
                expect(noMerge).to(beNil())
            }
            
            it("returns merged period if overlapping") {
                let merged = aPeriod(0, 10).periodMerged(aPeriod(10, 20))
                
                expect(merged?.start?.timeIntervalSince1970) == 0
                expect(merged?.end?.timeIntervalSince1970) == 20
            }
            
            it("returns merged period otherwise") {
                let merged = aPeriod(0, 10).periodMerged(aPeriod(5, 10))
                
                expect(merged?.start?.timeIntervalSince1970) == 0
                expect(merged?.end?.timeIntervalSince1970) == 10
            }
        }
        
        describe(".only(weekdays:)") {

            beforeEach {
                let monday = Date().dateAt(weekdayOrdinal: 1, weekday: .monday)
                let sunday = monday.dateAt(DateRelatedType.nextWeekday(.sunday))

                subject = [TimePeriod(startDate: monday, endDate: sunday)]
            }

            it("adds periods separately if weekdays are not contiguous") {
                let threeDays = subject.only(weekdays: [.monday, .wednesday, .friday])
                let twoDays = subject.only(weekdays: [.tuesday, .thursday])
                
                expect(threeDays.count) == 3
                expect(twoDays.count) == 2
            }

            it("combines periods if weekdays are contiguous") {
                let weekends = subject.only(weekdays: [.saturday, .sunday])
                let all = subject.only(weekdays: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday])
                let double = subject.only(weekdays: [.tuesday, .wednesday, .saturday, .sunday])
                
                expect(weekends.count) == 1
                expect(all.count) == 1
                expect(double.count) == 2
            }
            
            it("computes the times precisely") {
                let preciseMonday = Date().dateAt(weekdayOrdinal: 1, weekday: .monday).dateBySet(hour: 1, min: 2, secs: 3)!
                let preciseTuesday = preciseMonday.dateAt(DateRelatedType.nextWeekday(.tuesday)).dateBySet(hour: 3, min: 2, secs: 1)!
                let subject = [TimePeriod(startDate: preciseMonday, endDate: preciseTuesday)]
                
                let results = subject.only(weekdays: [.monday, .tuesday])
                
                expect(results.count) == 1
                expect(results.last?.start?.weekday) == WeekDay.monday.rawValue
                expect(results.last?.start?.hour) == 1
                expect(results.last?.start?.minute) == 2
                expect(results.last?.start?.second) == 3
                expect(results.last?.end?.weekday) == WeekDay.tuesday.rawValue
                expect(results.last?.end?.hour) == 3
                expect(results.last?.end?.minute) == 2
                expect(results.last?.end?.second) == 1
            }
            
            context("many periods") {
                it("returns the correct periods") {
                    let mon  = Date().dateAt(weekdayOrdinal: 1, weekday: .monday)
                    let tue  = mon.dateAt(.nextWeekday(.tuesday))
                    let thur = mon.dateAt(.nextWeekday(.thursday))
                    let sun  = mon.dateAt(.nextWeekday(.sunday))
                    
                    subject = [
                        TimePeriod(startDate: mon, endDate: tue),
                        TimePeriod(startDate: thur, endDate: sun),
                    ]
                    
                    let results = subject.only(weekdays: [.tuesday, .sunday])
                    
                    expect(results.count) == 2
                    expect(results.first?.start?.weekday) == WeekDay.tuesday.rawValue
                    expect(results.last?.start?.weekday) == WeekDay.sunday.rawValue
                }
            }
        }
        
        describe(".only(fromHours:)") {
            beforeEach {
                let someDate = Date()
                subject = [TimePeriod(startDate: someDate.dateAtStartOf(.day), endDate: someDate.dateAtEndOf(.day))]
            }

            it("returns periods that match the criteria")  {
                let results = subject.only(fromHours: [(start: 9, end: 17)])
                
                expect(results.count) == 1
                expect(results.first?.hours) == 8
                expect(results.first?.start?.hour) == 9
                expect(results.first?.end?.hour) == 17
            }
            
            it("combines periods if hours are contiguous") {
                let results = subject.only(fromHours: [(start: 0, end: 1), (start: 2, end: 3), (start: 10, end: 12)])

                expect(results.count) == 3
            }
            
            it("returns the correct periods across days") {
                let mon = Date().dateAt(weekdayOrdinal: 1, weekday: .monday).dateAtStartOf(.day)
                let wed = mon.dateAt(.nextWeekday(.wednesday))

                let subject = [TimePeriod(startDate: mon, endDate: wed)]

                let results = subject.only(fromHours: [(start: 9, end: 17)])

                expect(results.count) == 2
            }
        }
        
        describe("periodsMerged()") {
            it("merges the overlapped periods") {
                let overlapping = [
                    aPeriod(0, 10),
                    aPeriod(5, 10),
                    aPeriod(20, 30),
                    aPeriod(30, 40),
                ]
                
                let merged = overlapping.periodsShallowMerged()
                
                expect(merged.count) == 2
                expect(merged.first?.start?.timeIntervalSince1970) == 0
                expect(merged.first?.end?.timeIntervalSince1970) == 10
                expect(merged.last?.start?.timeIntervalSince1970) == 20
                expect(merged.last?.end?.timeIntervalSince1970) == 40
            }

            it("does not merge distinct periods") {
                let distinct = [
                    aPeriod(0, 5),
                    aPeriod(10, 20),
                ]
                
                let noMerge = distinct.periodsShallowMerged()
                
                expect(noMerge.count) == 2
                expect(noMerge.first?.start?.timeIntervalSince1970) == 0
                expect(noMerge.first?.end?.timeIntervalSince1970) == 5
                expect(noMerge.last?.start?.timeIntervalSince1970) == 10
                expect(noMerge.last?.end?.timeIntervalSince1970) == 20
            }

            xit("recursively merges the periods") {}
        }
        
        describe("encloses(with:)") {
            it("returns true") {
                let subject = [
                    aPeriod(0, 10),
                    aPeriod(10, 20)
                ]
                let suggestion = aPeriod(5, 15)
                
                let res = subject.encloses(with: suggestion)

                expect(res) == true
            }
        }
        
        describe("periodsRoundedIf(_:)") {
            it("cannot round because no availability") {
                let subject = [
                    TimePeriod(start: DateInRegion("2019-08-01T04:32:00Z")!, duration: 1.hours)
                ]
                
                let rounded = subject.periodsRounded(.toCeilMins(60), within: subject)

                expect(rounded).to(beEmpty())
            }
            
            it("rounds") {
                let subject = [
                    TimePeriod(start: DateInRegion("2019-08-01T04:32:00Z")!, duration: 1.hours),
                    TimePeriod(start: DateInRegion("2019-08-01T05:32:00Z")!, duration: 1.hours),
                ]
                
                let rounded = subject.periodsRounded(.toCeilMins(60), within: [TimePeriod(startDate: Date.distantPast, endDate: Date.distantFuture)])
                
                expect(rounded.count) == 2
                expect(rounded.first?.start?.dateComponents.hour) == 5
                expect(rounded.first?.start?.dateComponents.minute) == 0
                expect(rounded.last?.start?.dateComponents.hour) == 6
                expect(rounded.first?.start?.dateComponents.minute) == 0
            }

            it("cannot round because disjoint") {
//                fatalError("Not yet implemented")
            }
            
            it("does not cause a double round error") {
                let subject = [
                    TimePeriod(start: DateInRegion("2019-08-01T04:32:00Z")!, duration: 1.hours),
                    TimePeriod(start: DateInRegion("2019-08-01T04:32:00Z")!, duration: 1.hours),
                ]
            }
        }
    }
}
