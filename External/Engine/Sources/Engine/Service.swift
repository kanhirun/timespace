import Foundation
import SwiftDate
import SwiftyJSON

public struct Service {
    public let name: String
    public let duration: TimeInterval
    
    // MARK: - JSON
    
    init(name: String, duration: TimeInterval) {
        self.name = name
        self.duration = duration
    }
    
    public init(fromJSON json: JSON) {
        self.name = json["name"].stringValue
        self.duration = TimeInterval(json["duration"].stringValue)!
    }

    func toJSON() -> JSON {
        var res = JSON()
        res["name"].string = name
        res["duration"].string = String(duration)
        
        return res
    }
}
