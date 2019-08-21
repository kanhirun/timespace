import JTAppleCalendar
import UIKit
import SwiftDate

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    // The next button on the nav bar
    private var nextButton: UIBarButtonItem!

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
    
    @objc func didTapTextButton() {
        print("Compose message!")
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
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(view: cell, cellState: cellState)
    }
    
    /// MARK: - Header
    
    func calendar(_ calendar: JTAppleCalendarView,
                  headerViewForDateRange range: (start: Date, end: Date),
                  at indexPath: IndexPath) -> JTAppleCollectionReusableView {

        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "DateHeader", for: indexPath) as! DateHeader
        let refDate = range.start

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

        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell",for: indexPath) as! DateCell
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
        guard let cell = view as? DateCell else {
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
