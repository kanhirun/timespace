import UIKit
import JTAppleCalendar
import enum Messages.MSMessagesAppPresentationStyle

class PickCalendarDatesViewController: UIViewController {
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    var viewModel = PickCalendarDatesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        calendarView.calendarDataSource = viewModel
        calendarView.calendarDelegate = self as JTAppleCalendarViewDelegate
        calendarView.allowsMultipleSelection = true

        calendarView.scrollToDate(Date(), animateScroll: false)
    }

}

extension PickCalendarDatesViewController: PresentationViewDelegate {
    func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {}
    func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {}
}

extension PickCalendarDatesViewController: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        let cell = cell as! CalendarDateCellV2
        viewModel.select(viewModel: cell.viewModel!)
        cell.updateUI()  // todo: need KVO
    }

    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        let cell = cell as! CalendarDateCellV2
        viewModel.deselect(viewModel: cell.viewModel!)
        cell.updateUI()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        let cell = cell as! CalendarDateCellV2
        return viewModel.isSelectable(viewModel: cell.viewModel!)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(
            withReuseIdentifier: "CalendarDateCellV2",
            for: indexPath) as! CalendarDateCellV2

        if cellState.dateBelongsTo == .previousMonthOutsideBoundary {
            cell.isHidden = true
        } else {
            cell.isHidden = false
        }

        cell.viewModel = viewModel.dateViewModel(for: date)
        

        return cell
    }

    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = calendar.dequeueReusableJTAppleCell(
            withReuseIdentifier: "CalendarDateCellV2",
            for: indexPath) as! CalendarDateCellV2
        
        cell.viewModel = viewModel.dateViewModel(for: date)
    }
}
