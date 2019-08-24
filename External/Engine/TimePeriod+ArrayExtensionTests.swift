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

        describe(".toJSON()") {
            it("converts empty array to empty JSON array") {
                let empty = [TimePeriod]()
                let results = empty.toJSON()

                expect(results.arrayValue).to(beEmpty())
            }
            
            it("converts periods to JSON and back") {
                let periods = [
                    TimePeriod(start: DateInRegion("2019-11-11T11:11:11Z")!,
                               end: DateInRegion("2019-08-01T10:00:00Z")!),
                ]

                let results = periods.toJSON()
                
                expect(results.arrayValue.count) == 1
                
                // back to JSON
                let str = results.rawString()!
                let json = JSON(parseJSON: str)
                
                expect(json[0]["start"]) == "2019-11-11T11:11:11Z"
                expect(json[0]["end"]) == "2019-08-01T10:00:00Z"
            }
        }
    }
}
