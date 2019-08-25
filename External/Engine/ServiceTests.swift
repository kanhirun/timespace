import Quick
import Nimble

import SwiftyJSON
@testable import Engine

final class ServiceTests: QuickSpec {
    override func spec() {
        describe("Service") {

            describe("JSON") {
                it("converts into JSON type") {
                    let service = Service(name: "service-name", duration: 10.days)
                    
                    let subject = service.toJSON()
                    
                    expect(subject["name"].string) == "service-name"
                    expect(subject["duration"].string) == 10.days.timeInterval.toString()
                }
                
                it("converts from JSON type") {
                    var json = JSON()
                    json["name"] = "service-name"
                    json["duration"] = "432000"  // or 5 days (in seconds)
                    
                    let subject = Service(fromJSON: json)
                    
                    expect(subject.name) == "service-name"
                    expect(subject.duration) == 432000.seconds
                }
            }
            
        }
    }
}
