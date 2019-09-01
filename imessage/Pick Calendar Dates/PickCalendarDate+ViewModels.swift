import SwiftDate
import JTAppleCalendar
import Engine
import Messages


private let defaultSchedule = ScheduleService(start: Date(), end: 2.months.fromNow)

class PickCalendarDatesViewModel: JTAppleCalendarViewDataSource {
    
    var presentationStyle: MSMessagesAppPresentationStyle = .compact

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
        scheduleService: ScheduleService = defaultSchedule,
        conversation: MSConversation? = nil
    ) {
        self.calendar = calendarService
        self.schedule = scheduleService
        self.service = serviceRepository
        self.conversation = conversation
    }
    
    func dateViewModel(for date: Date) -> CalendarDateViewModel? {
        // todo: Figure out how to retain selections
        return CalendarDateViewModel(date: date)
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
    
    func select(date: Date, viewModel: CalendarDateViewModel) {
        if selectedPeriods.count <= maxCount && viewModel.viewState == .available {
            viewModel.select()

            let startDate = date.convertTo(region: Region.local)
                                .dateAtStartOf(.day).date
            let endDate = startDate.dateByAdding(1, .day).date
            let wholeDayPeriod = TimePeriod(startDate: startDate, endDate: endDate)

            selectedPeriods.append(wholeDayPeriod)
        }
    }
    
    func deselect(date: Date, viewModel: CalendarDateViewModel) {
        if viewModel.viewState == .selected {
            viewModel.deselect()

            selectedPeriods.removeAll { $0.startDate == date }
        }
    }
    
    // MARK: - Data Source
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        return ConfigurationParameters(startDate: schedule.start.date,
                                       endDate: schedule.end.date,
                                       numberOfRows: 6,
                                       generateInDates: .forFirstMonthOnly,
                                       generateOutDates: .off,
                                       firstDayOfWeek: .monday,
                                       hasStrictBoundaries: false)
    }
}


class CalendarDateViewModel {
    
    enum ViewState {
        case selected
        case available
        case unavailable
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
    
    /// The alpha quickly informing users how busy that day is
    /// e.g., 1.0 = busy, 0.0 = free
    var alphaBusyOrNotBusy: CGFloat {
        return CGFloat.random(in: 0.0...1.0 )
    }
    
    private(set) var viewState: ViewState = .unavailable
    private let date: Date

    init(date: Date) {
        self.date = date
        
        viewState = date.isInPast ? .unavailable : .available
    }
    
    func isToday() -> Bool {
        return date.isToday
    }
    
    func select() {
        viewState = .selected
    }
    
    func deselect() {
        viewState = date.isInPast ? .unavailable : .available
    }
}
