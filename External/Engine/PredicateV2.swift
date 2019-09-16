import Quick
import Nimble

import Foundation
import SwiftDate
@testable import Engine


// Returns the time interval for a date that is advanced by component
func timeInterval(for date: Date, advancedBy components: DateComponents) -> TimeInterval {
    if let futureDate = projectedDate(from: date, advancedBy: components), futureDate > date {
        return futureDate.timeIntervalSince(date)
    }
    
    return 0
}

// Returns a new date when advanced by component
func projectedDate(from other: Date, advancedBy components: DateComponents) -> Date? {
    var result = other.calendar.nextDate(after: other,
                                         matching: components,
                                         matchingPolicy: .nextTime,
                                         repeatedTimePolicy: .first)
    // Advance by timezone
    let timeZoneOffset = components.timeZone?.secondsFromGMT(for: other) ?? 0
    result?.addTimeInterval(-TimeInterval(timeZoneOffset))

    return result
}

final class PredicateV2Tests: QuickSpec {
    override func spec() {

        describe("timeInterval(for:advancedBy:)") {
            describe("complex cases") {
                it("calculates when combining components") {
                    let aDate = Date("2019-09-16T00:00:00Z")!
                    
                    let wednesdayAt9 = DateComponents(timeZone: Zones.americaNewYork.toTimezone(),
                                                      hour: 9,
                                                      weekday: WeekDay.wednesday.rawValue)
                    
                    let res = projectedDate(from: aDate, advancedBy: wednesdayAt9)
                    
                    expect(res) == Date("2019-09-18T09:00:00-04:00")!
                }

                it("returns 0 when the year component is behind") {
                    let aDate = Date("2019-09-16T02:00:00Z")!
                    
                    // year component is behind
                    let backIn1990 = DateComponents(year: 1990, day: 13, hour: 10)
                    
                    let res = timeInterval(for: aDate, advancedBy: backIn1990)
                    
                    expect(res) == 0
                }
                
                it("calculates next month when day component is behind") {
                    let aDate = Date("2019-09-16T02:00:00Z")!
                    
                    // the day component is behind the current day
                    let aComponent = DateComponents(day: 13, hour: 10)
                    
                    let res = timeInterval(for: aDate, advancedBy: aComponent)
                    
                    expect(res) == Date("2019-10-13T10:00:00Z")!.timeIntervalSince(aDate)
                }
            }

            describe("simple cases") {
                xit("can calculate for month") {
                    let aDate = Date("2019-09-16T00:00:00Z")!

                    let res = projectedDate(from: aDate, advancedBy: DateComponents(month: 10))
                    
                    expect(res) == Date("2019-10-10T00:00:00Z")!
                }

                it("can calculate for hour") {
                    let aDate = Date("2019-09-16T02:00:00Z")!

                    let res = timeInterval(for: aDate, advancedBy: DateComponents(hour: 9))
                    
                    expect(res) == 7.hours.timeInterval
                }
                
                it("can calculate for day and hour") {
                    let aDate = Date("2019-09-16T02:00:00Z")!

                    let res = timeInterval(for: aDate, advancedBy: DateComponents(day: 17, hour: 4))
                    
                    expect(res) == 1.days.timeInterval + 2.hours.timeInterval
                }
                
                it("can calculate for minute") {
                    let aDate = Date("2019-09-16T02:00:00Z")!

                    let res = timeInterval(for: aDate, advancedBy: DateComponents(minute: 30))
                    
                    expect(res) == 30.minutes.timeInterval
                }
                
                it("can calculate for weekday component") {
                    let aDate = Date("2019-09-16T00:00:00Z")!  // a monday

                    let res = timeInterval(for: aDate, advancedBy: DateComponents(weekday: WeekDay.wednesday.rawValue))
                    
                    expect(res) == 2.days.timeInterval
                }
                
                it("can calculate for seconds") {
                    let aDate = Date("2019-09-16T00:00:10Z")!

                    let res = timeInterval(for: aDate, advancedBy: DateComponents(second: 33))
                    
                    expect(res) == 23.seconds.timeInterval
                }
                
                it("can calculate for timezone") {
                    let aDate = Date("2019-09-16T5:00:10Z")!
                    
                    let res = timeInterval(for: aDate, advancedBy: DateComponents(timeZone: TimeZone(identifier: "EST")!, hour: 10))
                    
                    expect(res) == 10.hours.timeInterval
                }
            }
        }
    }
}
