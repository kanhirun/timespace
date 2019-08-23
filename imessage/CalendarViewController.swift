import JTAppleCalendar
import UIKit
import SwiftDate
import Messages

class CalendarViewController: UIViewController,
                              JTAppleCalendarViewDelegate,
                              JTAppleCalendarViewDataSource {

    @IBOutlet weak var calendarView: CalendarView!

    var model: CalendarViewModel!
    var activeConversation: MSConversation? = nil
    
    // MARK: - Controller
    
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
        let calendar = composeCalendarSnapshot()

        activeConversation?.insert(calendar) { err in
            debugPrint(err as Any)
        }
    }
    
    // TODO: Subclass JTAppleCalendarView with CalendarView that re-types the objects
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
            withReuseIdentifier: "DateHeader", for: indexPath) as! CalendarHeader

        header.sendButton.addTarget(self, action: #selector(send), for: .primaryActionTriggered)
        header.updateUI(range)
        
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
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! CalendarDateCell
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
    
    private func composeCalendarSnapshot() -> MSMessage {
        let layout = MSMessageTemplateLayout()
        layout.image = getSnapshotImage()
        let session = MSSession()
        let msg = MSMessage(session: session)
        msg.layout = layout
        
        return msg
    }
    
    private func getSnapshotImage() -> UIImage {
        let data: [TimePeriod] = [
            TimePeriod(start: DateInRegion("2019-08-22T09:00:00Z")!, duration: 1.hours),
            TimePeriod(start: DateInRegion("2019-08-22T16:55:55Z")!, duration: 1.hours),
            TimePeriod(start: DateInRegion("2019-08-22T20:30:55Z")!, duration: 1.hours),
            TimePeriod(start: DateInRegion("2019-08-23T05:00:55Z")!, duration: 1.hours),
            TimePeriod(start: DateInRegion("2019-08-24T05:00:55Z")!, duration: 1.hours),
        ]
        return TimeSheetView(periods: data, frame: CGRect(x: 0, y: 0, width: 150, height: 150)).asImage()
    }
}


extension UIImage {
    func imageScaledToSize(size: CGSize) -> UIImage {
        //create drawing context
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        //draw
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        //capture resultant image
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext();
        
        return image
    }
    
    func imageScaledToFitSize(size: CGSize) -> UIImage {
        //calculate rect
        let aspect = self.size.width / self.size.height
        
        if (size.width / aspect <= size.height) {
            return self.imageScaledToSize(size: CGSize(width: size.width, height: size.width / aspect))
        } else {
            return self.imageScaledToSize(size: CGSize(width: size.height * aspect, height: size.height))
        }
    }
}
