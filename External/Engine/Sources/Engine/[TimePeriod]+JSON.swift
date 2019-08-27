import SwiftDate
import SwiftyJSON

public extension Array where Element : TimePeriod {
    func toJSON() -> JSON {
        let arr = map { $0.toJSON() }

        return JSON(arr)
    }
    
    static func fromJSON(_ json: JSON) -> [TimePeriod] {
        return (json.arrayValue).map {
            TimePeriod(fromJSON: $0)
        }
    }
}
