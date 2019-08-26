import SwiftDate
import SwiftyJSON

extension TimePeriod {
    func toJSON() -> JSON {
        return JSON([
            "start": start!.toISO(),
            "end": end!.toISO()
        ])
    }
}

public extension Array where Element : TimePeriod {
    func toJSON() -> JSON {
        let arr = self.map { $0.toJSON() }
        
        return JSON(arr)
    }
    
    static func fromJSON(_ json: JSON) -> [TimePeriod] {
        guard let arr = json.array else {
            return [TimePeriod]()
        }
        
        let mapped = arr.map { jsonPeriod -> TimePeriod in
            let start = DateInRegion(jsonPeriod["start"].stringValue)!
            let end = DateInRegion(jsonPeriod["end"].stringValue)!
            
            return TimePeriod(start: start, end: end)
        }
        
        return mapped
    }
}
