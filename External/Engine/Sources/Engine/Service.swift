import Foundation
import SwiftDate
import SwiftyJSON

public struct Service {
    public let name: String
    public let duration: TimeInterval
    
    init(name: String, duration: TimeInterval) {
        self.name = name
        self.duration = duration
    }
}
