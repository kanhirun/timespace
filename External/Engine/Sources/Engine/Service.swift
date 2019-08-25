import Foundation
import SwiftDate
import SwiftyJSON

public struct Service {
    public let name: String
    public let duration: DateComponents
    
    // MARK: - JSON
    
    init(name: String, duration: DateComponents) {
        self.name = name
        self.duration = duration
    }
    
    init(fromJSON json: JSON) {
        self.name = json["name"].stringValue
        self.duration = toDateComponents(json["duration"].stringValue)
    }

    func toJSON() -> JSON {
        var res = JSON()
        res["name"].string = name
        res["duration"].string = duration.timeInterval.toString()
        
        return res
    }
}

private func toDateComponents(_ str: String) -> DateComponents {
    return DateComponents(second: Int(str)!)
}
