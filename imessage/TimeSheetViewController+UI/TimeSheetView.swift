import UIKit
import SwiftDate

private extension UIImage {
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


class TimeSheetView: UIStackView {
    
    private let periods: [TimePeriod]
    private weak var controller: TimeSheetViewController?
    
    init(periods: [TimePeriod], controller: TimeSheetViewController? = nil, frame: CGRect = CGRect.zero) {
        self.periods = periods
        self.controller = controller
        
        super.init(frame: frame)

        axis = .horizontal
        alignment = .top
        distribution = .fill
        translatesAutoresizingMaskIntoConstraints = false
        
        clipsToBounds = false

        // Adds a white background to the stack view
        let subView = UIView(frame: bounds)
        subView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
        
        createViews()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func asImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)

        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()!

        UIGraphicsEndImageContext()

        return image
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if let superview = superview {
            let columnsToAdjustWidth = self.arrangedSubviews

            columnsToAdjustWidth.forEach { column in
                column.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: 0.33).isActive = true
            }
        }
    }
    
    // MARK: - Private

    private func createViews() {
        guard periods.count > 0 else {
            return
        }
        
        // Pointer for tracking whether a new column should be created
        var currDay: Int? = nil
        var currColumn: UIStackView!
        
        periods.forEach { period in
            if (currDay == nil || period.start!.day > currDay! ) {
                currColumn = createColumnView(period)

                addArrangedSubview(currColumn!)

                currDay = period.start?.day
            }

            let timeCell: AppointmentCell = .fromNib()
            timeCell.updateUI(period)
            timeCell.timeButton.addTarget(self, action: #selector(TimeSheetView.selectAppointment(sender:)), for: .primaryActionTriggered)

            currColumn.addArrangedSubview(timeCell)
        }
    }
    
    @objc func selectAppointment(sender: TimeButton) {
        controller?.selectAppointment(period: sender.period)
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
}
