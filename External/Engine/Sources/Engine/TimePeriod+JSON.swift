import SwiftDate
import SwiftyJSON

extension TimePeriod {
    
    convenience init(fromJSON json: JSON) {
        let start = DateInRegion(json["start"].stringValue)!
        let end = DateInRegion(json["end"].stringValue)!

        self.init(start: start, end: end)
    }
    
    func toJSON() -> JSON {
        return JSON([
            "start": start!.toISO(),
            "end": end!.toISO()
        ])
    }
}
