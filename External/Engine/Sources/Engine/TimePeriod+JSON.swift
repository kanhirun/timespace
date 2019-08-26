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
