import SwiftyJSON
import Foundation

extension Service {
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
