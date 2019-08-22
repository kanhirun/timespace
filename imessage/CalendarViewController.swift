import JTAppleCalendar
import UIKit
import SwiftDate
import Messages

class CalendarViewController: UIViewController,
                              JTAppleCalendarViewDelegate,
                              JTAppleCalendarViewDataSource {

    @IBOutlet weak var calendarView: JTAppleCalendarView!

    var model: CalendarViewModel!
    var activeConversation: MSConversation? = nil
    
    // MARK: - Controller

    override func viewDidLoad() {
        super.viewDidLoad()

        calendarView.allowsMultipleSelection = true
        calendarView.scrollDirection = .horizontal
        calendarView.scrollingMode   = .stopAtEachCalendarFrame
        calendarView.showsHorizontalScrollIndicator = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Actions
    
    @objc func send() {
        let layout = MSMessageTemplateLayout()
        layout.image = getSnapshotImage()
        let session = MSSession()
        let msg = MSMessage(session: session)
        msg.layout = layout

        activeConversation?.insert(msg) { err in
            debugPrint(err as Any)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView,
                  didSelectDate date: Date,
                  cell: JTAppleCell?,
                  cellState: CellState) {
        updateUI(cell, with: cellState)
        model.select(date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        updateUI(cell, with: cellState)
        model.unselect(date)
    }
    
    // MARK: - Calendar Appearance
    
    // Adjusts calendar view
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        return ConfigurationParameters(
            startDate: model.startDate,
            endDate:  model.endDate,
            numberOfRows: 2,
            generateOutDates: .tillEndOfRow,
            firstDayOfWeek: .monday,
            hasStrictBoundaries: false
        )
    }
    
    // Adjusts header cell
    func calendar(_ calendar: JTAppleCalendarView,
                  headerViewForDateRange range: (start: Date, end: Date),
                  at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        
        let header = calendar.dequeueReusableJTAppleSupplementaryView(
            withReuseIdentifier: "DateHeader", for: indexPath) as! CalendarDateHeader
        let refDate = range.start
        
        header.sendButton.addTarget(self, action: #selector(send), for: .primaryActionTriggered)
        header.monthLabel.text = "\(refDate.monthName(.default)) \(refDate.toFormat("YYYY"))"
        
        return header
    }
    
    // Adjusts header height
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return MonthSize(defaultSize: 100)
    }
    
    // Adjusts calendar date cell
    func calendar(_ calendar: JTAppleCalendarView,
                  cellForItemAt date: Date,
                  cellState: CellState,
                  indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell",for: indexPath) as! CalendarDateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        updateUI(cell, with: cellState)
    }
    
    // MARK: - Private

    private func updateUI(_ view: JTAppleCell?, with cellState: CellState) {
        if let cell = view as? CalendarDateCell {
            cell.updateUI(cellState)
        }
    }
    
    // TODO: Should be an attribute of the next controller
    private func getSnapshotImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(calendarView.bounds.size, calendarView.isOpaque, 0.0)
        calendarView.drawHierarchy(in: calendarView.bounds, afterScreenUpdates: false)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return snapshotImage
    }
}
