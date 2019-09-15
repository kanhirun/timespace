import Quick
import Nimble

import Foundation
import SwiftDate
@testable import Engine

func compute(_ date: Date, _ components: DateComponents) -> TimeInterval {
    var projectedDate = date.dateBySet([
        .month : components.month ?? date.month,
        .day : components.day ?? date.day,
        .hour : components.hour ?? date.hour,
        .minute: components.minute ?? date.minute,
        .second: components.second ?? date.second,
    ])
    
    if let weekday = components.weekday, let nextWeekday = WeekDay(rawValue: weekday) {
        projectedDate = projectedDate?.nextWeekday(nextWeekday)
    }
    
    var offset: TimeInterval = 0
    if let timeZone = components.timeZone {
        offset = -TimeInterval(timeZone.secondsFromGMT(for: date))
    }

    if let res = projectedDate?.timeIntervalSince(date), res + offset > 0 {
        return res + offset
    } else {
        return 0.0
    }
}

final class PredicateTests: QuickSpec {
    override func spec() {
        describe("compute()") {
            context("when fast-forwarding") {
                it("calculates when components is months") {
                    let aDate = Date("2019-09-16T00:00:00Z")!
                    let aComponent = DateComponents(month: 10)
                    let res = compute(aDate, aComponent)
                    
                    expect(res) == 30.days.timeInterval
                }

                it("calculates when components is hour") {
                    let aDate = Date("2019-09-16T02:00:00Z")!
                    let aComponent = DateComponents(hour: 9)
                    let res = compute(aDate, aComponent)
                    
                    expect(res) == 7.hours.timeInterval
                }
                
                it("calculates when day and hour") {
                    let aDate = Date("2019-09-16T02:00:00Z")!
                    let aComponent = DateComponents(day: 17, hour: 4)
                    let res = compute(aDate, aComponent)
                    
                    expect(res) == 1.days.timeInterval + 2.hours.timeInterval
                }
                
                it("calculates when minutes") {
                    let aDate = Date("2019-09-16T02:00:00Z")!
                    let aComponent = DateComponents(minute: 30)
                    let res = compute(aDate, aComponent)
                    
                    expect(res) == 30.minutes.timeInterval
                }
                
                it("calculates when weekdays") {
                    let aDate = Date("2019-09-16T00:00:00Z")!
                    let aComponent = DateComponents(weekday: WeekDay.wednesday.rawValue)
                    let res = compute(aDate, aComponent)
                    
                    expect(res) == 2.days.timeInterval
                }
                
                it("calculates when seconds") {
                    let aDate = Date("2019-09-16T00:00:10Z")!
                    let aComponent = DateComponents(second: 33)
                    let res = compute(aDate, aComponent)
                    
                    expect(res) == 23.seconds.timeInterval
                }
                
                it("calculates timezone differences") {
                    let aDate = Date("2019-09-16T5:00:10Z")!
                    let aComponent = DateComponents(timeZone: TimeZone(identifier: "EST")!, hour: 10)
                    
                    let res = compute(aDate, aComponent)
                    
                    expect(res) == 10.hours.timeInterval
                }
            }
            
            it("returns 0 when in the past") {
                let aDate = Date("2019-09-16T02:00:00Z")!
                let aComponent = DateComponents(day: 13, hour: 23)
                let res = compute(aDate, aComponent)

                expect(res) == 0
            }
        }
    }
}
