import SwiftDate
import JTAppleCalendar
import Engine
import Messages


private let defaultService = ScheduleService(start: Date(), end: 2.months.fromNow)

class PickCalendarDatesViewModel: JTAppleCalendarViewDataSource {
    
    var presentationStyle: MSMessagesAppPresentationStyle = .compact
    
    private var selected = [TimePeriod]()
    private let maxCount = 3

    private let scheduleService: ScheduleService

    init(scheduleService: ScheduleService = defaultService) {
        self.scheduleService = scheduleService
    }
    
    func dateViewModel(for date: Date) -> CalendarDateViewModel? {
        // todo: Figure out how to retain selections
        return CalendarDateViewModel(date: date)
    }
    
    func isSelectable(viewModel: CalendarDateViewModel) -> Bool {
        return viewModel.viewState == .available && selected.count < maxCount
    }
    
    func getHeaderText(from date: Date) -> String {
        return "\(date.monthName(.default)) \(date.year)"
    }
    
    // todo: remove duplicate
    func getInitialHeaderText() -> String {
        let date = scheduleService.start
        return "\(date.monthName(.default)) \(date.year)"
    }
    
    func composeMessage() -> MSMessage {
        let message = MSMessage(session: MSSession())
        return message
    }
    
    // MARK: - Actions
    
    func select(date: Date, viewModel: CalendarDateViewModel) {
        if selected.count <= maxCount && viewModel.viewState == .available {
            viewModel.select()

            let wholeDayPeriod = TimePeriod(startDate: date.dateAtStartOf(.day),
                                            endDate: date.dateAtEndOf(.day))
            selected.append(wholeDayPeriod)
        }
    }
    
    func deselect(date: Date, viewModel: CalendarDateViewModel) {
        if viewModel.viewState == .selected {
            viewModel.deselect()

            selected.removeAll { $0.contains(date: DateInRegion(date, region: date.region)) }
        }
    }
    
    // MARK: - Data Source
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        return ConfigurationParameters(startDate: scheduleService.start.date,
                                       endDate: scheduleService.end.date,
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
