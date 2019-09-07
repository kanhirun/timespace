import Quick
import Nimble

import SwiftDate
import SwiftyJSON
@testable import Engine

class TimePeriodArrayJSONExtensionTests: QuickSpec {
    override func spec() {
        describe(".toJSON()") {
            it("converts empty array to empty JSON array") {
                let empty = TimePeriodCollection()
                let results = empty.toJSON()
                
                expect(results.arrayValue).to(beEmpty())
            }
            
            it("converts periods to JSON and back") {
                let periods = TimePeriodCollection([
                    TimePeriod(start: DateInRegion("2019-11-11T11:11:11Z")!,
                               end: DateInRegion("2019-08-01T10:00:00Z")!),
                ])
                
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
