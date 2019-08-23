import UIKit
import SwiftDate

class TimeSheetView: UIStackView {
    
    private let periods: [TimePeriod]
    
    init(periods: [TimePeriod], frame: CGRect = CGRect.zero) {
        self.periods = periods
        
        super.init(frame: frame)

        axis = .horizontal
        alignment = .top
        distribution = .fill
        translatesAutoresizingMaskIntoConstraints = false

        // Adds a white background to the stack view
        let subView = UIView(frame: bounds)
        subView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func asImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)

        drawHierarchy(in: bounds, afterScreenUpdates: true)

        let image = UIGraphicsGetImageFromCurrentImageContext()!

        UIGraphicsEndImageContext()

        return image.imageScaledToSize(size: CGSize(width: 200, height: 200))
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        createViews()
    }
    
    func createViews() {
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
                addArrangedSubview(currColumn!)

                // Lay it out
                if let superview = superview {
                    currColumn!.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: 0.33).isActive = true
                }
                
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
