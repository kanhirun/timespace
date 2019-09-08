import SwiftDate
import Engine

protocol ActionDelegate: class {
    func didAction(action: ViewAction)
}

enum ViewAction {
    case willBook(service: Service, period: TimePeriod)
    case didBook(service: Service, period: TimePeriod)
    case didSend
}
