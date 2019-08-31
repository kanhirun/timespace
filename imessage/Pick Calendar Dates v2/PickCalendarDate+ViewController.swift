import UIKit
import JTAppleCalendar
import SwiftDate
import Messages

import Engine

class PickCalendarDatesViewController: UIViewController {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    var viewModel: PickCalendarDatesViewModel!
    var conversation: MSConversation!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerLabel.text = viewModel.getInitialHeaderText()

        calendarView.calendarDataSource = viewModel
        calendarView.calendarDelegate = self as JTAppleCalendarViewDelegate
        calendarView.allowsMultipleSelection = true

        calendarView.scrollToDate(Date(), animateScroll: false)
        
        sendButton.addTarget(self, action: #selector(didAction), for: .primaryActionTriggered)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    @objc func didAction() {
        let message = viewModel.composeMessage()
        conversation.insert(message, completionHandler: nil)
    }

}

extension PickCalendarDatesViewController: MessageDelegate {
    func didStartSending(_ message: MSMessage, conversation: MSConversation) {}
    func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {}
    func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {}
}

extension PickCalendarDatesViewController: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        let cell = cell as! CalendarDateCellV2
        viewModel.select(date: date, viewModel: cell.viewModel!)
        cell.updateUI()  // todo: need KVO to remove dup
    }

    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        let cell = cell as! CalendarDateCellV2
        viewModel.deselect(date: date, viewModel: cell.viewModel!)
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
    
    func calendarDidScroll(_ calendar: JTAppleCalendarView) {
        guard let aDate = calendar.visibleDates().monthDates.first?.date else {
            return
        }

        headerLabel.text = viewModel.getHeaderText(from: aDate)
    }
}
