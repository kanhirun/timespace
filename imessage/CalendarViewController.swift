import JTAppleCalendar
import UIKit
import SwiftDate
import Messages

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendarView: JTAppleCalendarView!

    var activeConversation: MSConversation!
    
    /// The dates picked by the user
    var selectedPeriods = [TimePeriod]()

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
    
    /// MARK: - Button Actionss
    
    @objc func send() {
        let layout = MSMessageTemplateLayout()
        layout.image = getSnapshotImage()
        let session = MSSession()
        let msg = MSMessage(session: session)
        msg.layout = layout

        activeConversation.insert(msg) { err in
            debugPrint(err as Any)
        }
    }
    
    private func getSnapshotImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(calendarView.bounds.size, calendarView.isOpaque, 0.0)

        calendarView.drawHierarchy(in: calendarView.bounds, afterScreenUpdates: false)

        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()

        return snapshotImage
    }
}


extension CalendarViewController: JTAppleCalendarViewDataSource {

    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let startDate = Date("2019-08-19T00:00:00Z")!
        let endDate = Date("2019-08-25T00:00:00Z")!
        
        return ConfigurationParameters(
            startDate: startDate,
            endDate: endDate,
            numberOfRows: 2,
            generateOutDates: .tillEndOfRow,
            firstDayOfWeek: .monday,
            hasStrictBoundaries: false
        )
    }

}

extension CalendarViewController: JTAppleCalendarViewDelegate {
    
    /// MARK: - Selection
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
        
        let aDateInRegion = date.convertTo(region: Region.local).dateAtStartOf(.day)
        let aPeriod = TimePeriod(startDate: aDateInRegion.date,
                                 endDate: aDateInRegion.dateByAdding(1, .day).date)

        selectedPeriods.append(aPeriod)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {

        configureCell(view: cell, cellState: cellState)

        selectedPeriods.removeAll { period -> Bool in
            period.start?.day == date.day
        }
    }
    
    /// MARK: - Header
    
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
    
    /// MARK: - Cell

    func calendar(_ calendar: JTAppleCalendarView,
                  cellForItemAt date: Date,
                  cellState: CellState,
                  indexPath: IndexPath) -> JTAppleCell {

        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell",for: indexPath) as! CalendarDateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }

    func calendar(_ calendar: JTAppleCalendarView,
                  willDisplay cell: JTAppleCell,
                  forItemAt date: Date,
                  cellState: CellState,
                  indexPath: IndexPath) {

        configureCell(view: cell, cellState: cellState)
    }

    // Display
    private func configureCell(view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? CalendarDateCell else {
            return
        }

        cell.dateLabel.text = cellState.text
        cell.layer.cornerRadius =  13
        
        // Today
        if cellState.date.isToday {
            cell.backgroundColor = .lightGray
        } else {
            cell.backgroundColor = .white
        }

        // Selected
        if cellState.isSelected {
            cell.selectedView.isHidden = false
            cell.dateLabel.textColor = .white
        } else {
            cell.selectedView.isHidden = true
            cell.dateLabel.textColor = .black
        }
    }
    
}
