import JTAppleCalendar
import UIKit
import SwiftDate
import Messages
import Engine

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
        model.getResultsToSend(completion: { result in
            switch result {
            case .success(let response):
                let messageImage = self.composeCalendarSnapshot(data: response)

                self.activeConversation?.insert(messageImage) { err in
                    if let err = err {
                        debugPrint(err)
                        return
                    }
                }
            case .failure(let err):
                debugPrint(err)
            }
        })
    }
    
    // TODO: Subclass JTAppleCalendarView with CalendarView that re-types the objects
    func calendar(_ calendar: JTAppleCalendarView,
                  didSelectDate date: Date,
                  cell: JTAppleCell?,
                  cellState: CellState) {
        updateUI(cell, with: cellState)
        
        model.select(date)
        print(model.selectedPeriods)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        updateUI(cell, with: cellState)
        model.unselect(date)
        print(model.selectedPeriods)
    }
    
    // MARK: - Calendar Appearance
    
    // Adjusts calendar view
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        return ConfigurationParameters(
            startDate: model!.start.date,
            endDate:  model!.end.date,
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
    
    private func composeCalendarSnapshot(data: [TimePeriod]) -> MSMessage {
        // 200 x 500 for one
        // 300 x 400 for two
        // 600 x 540 for three
        let layout = MSMessageTemplateLayout()
        let sheet = TimeSheetView(periods: data, frame: CGRect(x: 0, y: 0, width: 300, height: 400))
        layout.image = sheet.asImage()

        let session = activeConversation?.selectedMessage?.session ?? MSSession()
        let msg = MSMessage(session: session)
        msg.layout = layout

        return msg
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
