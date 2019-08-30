import Quick
import Nimble

import SwiftDate
@testable import Engine

class TimePeriodJSONTests: QuickSpec {
    override func spec() {
        describe("toJSON()") {
            it("converts to JSON") {
                let subject = TimePeriod(
                    start: DateInRegion("2019-08-01T00:00:00Z")!,
                    end: DateInRegion("2019-09-22T22:22:22Z")!
                )
                
                let json = subject.toJSON()
                
                expect(json["start"].string) == "2019-08-01T00:00:00Z"
                expect(json["end"].string) == "2019-09-22T22:22:22Z"
            }
        }
    }
}
