import SwiftDate
import SwiftyJSON

public extension TimePeriodCollection {
    func toJSON() -> JSON {
        let arr = map { ($0 as! TimePeriod).toJSON() }

        return JSON(arr)
    }
    
    static func fromJSON(_ json: JSON) -> [TimePeriod] {
        return (json.arrayValue).map {
            TimePeriod(fromJSON: $0)
        }
    }
}
