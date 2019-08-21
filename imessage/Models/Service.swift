import Foundation
import SwiftDate

struct Service {
    let name: String
    let duration: DateComponents
}

struct JeanServices {
    static let models: [Service] = [
        Service(name: "Men's Haircut", duration: 45.minutes),
        Service(name: "Chemical: Color", duration: 2.hours),
        Service(name: "Blowdry", duration: 1.hours + 30.minutes),
        Service(name: "Updo", duration: 1.hours),
    ]
}
