//
//  CustomerTests.swift
//  EngineTests
//
//  Created by Feynman on 8/12/19.
//
import Quick
import Nimble

import Foundation
import SwiftDate
@testable import Engine

// swift date views the interval problem from a infinitesimally small

final class CustomerTests: QuickSpec {
    override func spec() {

        context("As Jean Jekal") {
            it("shows her availability") {
                // One of the salons that Jean rents is in George Town, where tz would be EST.
                let herRegion = Region(calendar: Calendars.gregorian, zone: TimeZone(abbreviation: "EST")!, locale: Locales.english)
                
                // When Jean checks the app for her availability, it looks at the present and 1 week ahead...
                let herCurrentTime = DateInRegion(components: DateComponents(year: 2019, month: 8, day: 12, hour: 12, minute: 26), region: herRegion)!

                let herNextWeek = [TimePeriod(start: herCurrentTime,
                                             // The app will continue looking for availability until the end of the day
                                            end: DateInRegion(components: DateComponents(year: 2019, month: 8, day: 19), region: herRegion)!)]
                
//                expect(herNextWeek.durationIn(.day)) == 6  // We should be getting 6, because of flooring function
//                expect(herNextWeek.durationIn(.hour)) == 11 + (24 * 6)  // the next 7 days, where we truncate the first.
//                expect(herNextWeek.start?.day) == 12
//                expect(herNextWeek.end?.day) == 18
                
                // Next, she applies her business hours, which is Wed-Sun from 9-5pm EST
                
                let res = herNextWeek.only(weekdays: [.wednesday, .thursday, .friday, .saturday, .sunday])
                                     .only(fromHours: [(start: 9, end: 17)])

                expect(res.count) == 5
                expect(res).to(allPass { t in
                    t?.start?.hour == 9 && t?.end?.hour == 17
                })
            }
        }

    }
}
