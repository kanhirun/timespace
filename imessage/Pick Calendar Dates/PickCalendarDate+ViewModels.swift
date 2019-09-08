import SwiftDate
import Engine
import Messages

class PickCalendarDatesViewModel {
    
    var presentationStyle: MSMessagesAppPresentationStyle = .compact
    
    let startDate: Date
    let endDate: Date

    private var selectedPeriods = [TimePeriod]()
    private let maxCount = 3
    private let tag = "\(PickCalendarDatesViewModel.self)"

    private let calendar: AppleCalendar
    private let service: ServiceRepository
    private let schedule: ScheduleService
    private let conversation: MSConversation?

    init(
        calendarService: AppleCalendar = AppleCalendar.shared,
        serviceRepository: ServiceRepository = ServiceRepository.shared,
        scheduleService: ScheduleService,
        conversation: MSConversation? = nil
    ) {
        self.calendar = calendarService
        self.schedule = scheduleService
        self.service = serviceRepository
        self.conversation = conversation
        self.startDate = scheduleService.start.date
        self.endDate = scheduleService.end.date
    }
    
    func dateViewModel(localDate: Date) -> CalendarDateViewModel? {
        // todo: Figure out how to retain selections
        return CalendarDateViewModel(localDate: localDate, availability: schedule.render(region: Region.local))
    }
    
    func isSelectable(viewModel: CalendarDateViewModel) -> Bool {
        return viewModel.viewState == .available && selectedPeriods.count < maxCount
    }
    
    func getHeaderText(from date: Date) -> String {
        return "\(date.monthName(.default)) \(date.year)"
    }
    
    // todo: remove duplicate
    func getInitialHeaderText() -> String {
        return getHeaderText(from: schedule.start.date)
    }
    
    // MARK: - Actions
    
    func composeMessage() -> MSMessage {
        let selectedService = service.value!

        let availability = schedule.min(only: selectedPeriods, tag: tag)
                                   .subtract(fromSource: calendar, tag: tag)
                                   .quantize(unit: selectedService.duration, tag: tag)
                                   .render(region: Region.local)  // not idempotent

        var components = URLComponents()
        components.queryItems = [
            availability.queryItem,
            selectedService.queryItem,
        ]
        let message = MSMessage(
            session: conversation?.selectedMessage?.session ?? MSSession()
        )
        let layout = MSMessageTemplateLayout()
        let args = ViewModel(
            periods: availability,
            service: selectedService,
            conversation: conversation!
        )
        layout.image = TimeSheetCollectionViewV2.toImage(viewModel: args)
        layout.caption = "Do these times work for you?"
        layout.subcaption = "Tap for options"
        message.layout = layout
        message.url = components.url!
        
        schedule.remove(withTag: tag)

        return message
    }
    
    func select(localDate: Date, viewModel: CalendarDateViewModel) {
        if selectedPeriods.count <= maxCount && viewModel.viewState == .available {
            viewModel.select()

            let startDate = localDate.date
            let endDate = startDate.dateByAdding(1, .day).date
            let wholeDayPeriod = TimePeriod(startDate: startDate, endDate: endDate)

            selectedPeriods.append(wholeDayPeriod)
        }
    }
    
    func deselect(localDate: Date, viewModel: CalendarDateViewModel) {
        if viewModel.viewState == .selected {
            viewModel.deselect()

            selectedPeriods.removeAll { $0.startDate == localDate }
        }
    }
}


class CalendarDateViewModel {
    
    enum ViewState {
        case selected
        case available
        case unavailable
    }
    
    enum BusyLevel {
        case high
        case medium
        case low
        case free
    }

    /// The text shown on the view
    /// e.g., `Aug 1` or `1`.
    var dateText: String {
        if date.day == 1 {
            return "\(date.monthName(.short))\n\(date.day)"
        } else {
            return "\(date.day)"
        }
    }
    
    /// Indicates to users how busy that day is
    ///
    /// - Note: Values are bucketed into 4 distinct levels
    var busyLevel: BusyLevel {
        switch rand {
        case _ where rand >= 0.75:
            return .high
        case _ where rand >= 0.50:
            return .medium
        case _ where rand >= 0.25:
            return .low
        default:
            return .free

        }
    }
    
    private(set) var viewState: ViewState = .unavailable
    private let rand: CGFloat
    private let period: TimePeriod
    private let date: DateInRegion
    private let availability: TimePeriodCollection

    init(localDate: Date, availability: TimePeriodCollection) {
        let start = localDate
        self.rand = CGFloat.random(in: 0.0...1.0)
        self.period = TimePeriod(startDate: start, endDate: start.dateByAdding(1, .day).date)
        self.date = DateInRegion(start)
        self.availability = availability
        deselect()
    }
    
    func isToday() -> Bool {
        return date.isToday
    }
    
    func select() {
        viewState = .selected
    }
    
    func deselect() {
        let availableTimes = availability.periodsInside(period: period) // wtf

        if availableTimes.count > 0 && !date.isInPast {
            viewState = .available
        } else {
            viewState = .unavailable
        }
    }
}
