import UIKit
import SwiftDate

class Timesheet: UIStackView {
    
    private let periods: [TimePeriod]
    
    init(periods: [TimePeriod]) {
        self.periods = periods
        
        super.init(frame: CGRect.zero)
        
        axis = .horizontal
        alignment = .top
        distribution = .fill
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        createViews(view: superview!)
    }
    
    func createViews(view: UIView) {
        guard periods.count > 0 else {
            return
        }
        
        // Pointer for tracking whether a new column should be created
        var currDay: Int? = nil
        var currColumn: UIStackView? = nil
        
        periods.forEach { period in
            // New column should be created
            if (currDay == nil || period.start!.day > currDay! ) {
                // Create new column
                currColumn = createColumnView(period)
                addTimeCell(to: currColumn!, ref: period)
                self.addArrangedSubview(currColumn!)
                
                // Lay it out
                currColumn!.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.33).isActive = true
                
                currDay = period.start?.day
            // Current column should be appended
            } else {
                addTimeCell(to: currColumn!, ref: period)
            }
        }
    }
    
    private func createColumnView(_ period: TimePeriod) -> UIStackView {
        let dateCell: DateCell = .fromNib()  // col header
        dateCell.updateUI(period)
        
        let columnView = UIStackView(arrangedSubviews: [dateCell])
        columnView.axis = .vertical
        columnView.alignment = .fill
        columnView.distribution = .fill
        
        return columnView
    }
    
    private func addTimeCell(to column: UIStackView, ref period: TimePeriod) {
        let timeCell: AppointmentCell = .fromNib()
        timeCell.updateUI(period)
        column.addArrangedSubview(timeCell)
    }
}
