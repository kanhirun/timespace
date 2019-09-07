import SwiftDate
import SwiftyJSON

public extension TimePeriodCollection {
    convenience init(fromJSON json: JSON) {
        let periods = json.arrayValue.map { TimePeriod(fromJSON: $0) }
        
        self.init(periods)
    }

    func toJSON() -> JSON {
        let arr = map { ($0 as! TimePeriod).toJSON() }

        return JSON(arr)
    }
}
