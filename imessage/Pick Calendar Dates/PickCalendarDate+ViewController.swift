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
    weak var actionDelegate: ActionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerLabel.text = viewModel.getInitialHeaderText()

        calendarView.calendarDataSource = self
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
        conversation.insert(message) { err in
            if let err = err {
                debugPrint(err)
                return
            }
            
            self.actionDelegate?.didAction(action: .didSend)
        }
    }

}

extension PickCalendarDatesViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        return ConfigurationParameters(startDate: viewModel.startDate,
                                       endDate: viewModel.endDate,
                                       numberOfRows: 6,
                                       generateInDates: .forFirstMonthOnly,
                                       generateOutDates: .off,
                                       firstDayOfWeek: .monday,
                                       hasStrictBoundaries: false)
    }
}

extension PickCalendarDatesViewController: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        let cell = cell as! CalendarDateCell
        viewModel.select(localDate: date, viewModel: cell.viewModel!)
        cell.updateUI()  // todo: need KVO to remove dup
    }

    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        let cell = cell as! CalendarDateCell
        viewModel.deselect(localDate: date, viewModel: cell.viewModel!)
        cell.updateUI()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        let cell = cell as! CalendarDateCell
        return viewModel.isSelectable(viewModel: cell.viewModel!)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(
            withReuseIdentifier: "CalendarDateCell",
            for: indexPath) as! CalendarDateCell

        if cellState.dateBelongsTo == .previousMonthOutsideBoundary {
            cell.isHidden = true
        } else {
            cell.isHidden = false
        }

        cell.viewModel = viewModel.dateViewModel(localDate: date)
        

        return cell
    }

    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = calendar.dequeueReusableJTAppleCell(
            withReuseIdentifier: "CalendarDateCell",
            for: indexPath) as! CalendarDateCell
        
        cell.viewModel = viewModel.dateViewModel(localDate: date)
    }
    
    func calendarDidScroll(_ calendar: JTAppleCalendarView) {
        guard let aDate = calendar.visibleDates().monthDates.first?.date else {
            return
        }

        headerLabel.text = viewModel.getHeaderText(from: aDate)
    }
}
