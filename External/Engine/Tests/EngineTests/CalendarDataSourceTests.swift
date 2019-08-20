import Quick
import Nimble

import SwiftDate
import Alamofire
import Foundation
@testable import Engine

final class CalendarDataSourceTests: QuickSpec {
    override func spec() {
        
        describe("GoogleCalendar") {
            describe("filters") {
                it("returns the calendar source") {
                    let connected = GoogleCalendarV3(calid: "some-email@gmail.com", sessionManager: postmanSessionManager)
                    let region = Region(calendar: Calendars.gregorian, zone: Zones.americaNewYork, locale: Locales.english)
                    
                    let subject = Filters(start: DateInRegion(Date("2019-07-15T00:00:00-04:00")!, region: region),
                                          end: DateInRegion(Date("2019-07-22T00:00:00-04:00")!, region: region))
                    
                    waitUntil(timeout: 2) { done in
                        subject.min(only: (start: 9, end: 17), tag: "some-tag")
                        subject.subtract(fromSource: connected, tag: "some-tag", onSuccess: {
                            let response = subject.apply(region: region)

                            expect(response.count) == 8

                            expect(response.first?.start?.toISO()) == "2019-07-15T09:00:00-04:00"
                            expect(response.first?.end?.toISO()) == "2019-07-15T17:00:00-04:00"

                            expect(response.last?.start?.toISO()) == "2019-07-21T09:00:00-04:00"
                            expect(response.last?.end?.toISO()) == "2019-07-21T16:00:00-04:00"
                            
                            done()
                        }, onFailure: nil)
                    }
                }
            }
        }

    }
}
