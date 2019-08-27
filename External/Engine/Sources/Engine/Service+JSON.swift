import SwiftyJSON
import Foundation

extension Service {
    public convenience init(fromJSON json: JSON) {
        let name = json["name"].stringValue
        let duration = TimeInterval(json["duration"].stringValue)!

        self.init(name: name, duration: duration)
    }

    func toJSON() -> JSON {
        var res = JSON()
        res["name"].string = name
        res["duration"].string = String(duration)
        
        return res
    }
}
