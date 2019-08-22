import UIKit
import SwiftDate

class Timesheet: UIStackView {
    
    private let data: [TimePeriod]

    init(data: [TimePeriod]) {
        self.data = data
        
        super.init(frame: CGRect.zero)

        axis = .horizontal
        alignment = .top
        distribution = .fill
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func createColumnView(_ period: TimePeriod) -> UIStackView {
        let dateCell: DateCell = .fromNib()  // col header
        dateCell.updateUI(period)
        
        let columnView = UIStackView(arrangedSubviews: [dateCell])
        columnView.axis = .vertical
        columnView.alignment = .fill
        columnView.distribution = .fill
        
        return columnView
    }
    
    static func addTimeCell(to column: UIStackView, ref period: TimePeriod) {
        let timeCell: AppointmentCell = .fromNib()
        timeCell.updateUI(period)
        column.addArrangedSubview(timeCell)
    }
    
    func createViews(view: UIView) {
        guard data.count > 0 else {
            return
        }
        
        let safeArea = view.safeAreaLayoutGuide
        
        // Pointer for tracking whether a new column should be created
        var currDay: Int? = nil
        var currColumn: UIStackView? = nil
        
        data.forEach { period in
            // New column should be created
            if (currDay == nil || period.start!.day > currDay! ) {
                // Create new column
                currColumn = Timesheet.createColumnView(period)
                Timesheet.addTimeCell(to: currColumn!, ref: period)
                self.addArrangedSubview(currColumn!)
                
                // Lay it out
                currColumn!.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.33).isActive = true
                
                currDay = period.start?.day
                // Current column should be appended
            } else {
                Timesheet.addTimeCell(to: currColumn!, ref: period)
            }
        }
        
    }
}

class DateTimeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let data: [TimePeriod] = [
            TimePeriod(start: DateInRegion("2019-08-22T09:00:00Z")!, duration: 1.hours),
            TimePeriod(start: DateInRegion("2019-08-22T16:55:55Z")!, duration: 1.hours),
            TimePeriod(start: DateInRegion("2019-08-22T20:30:55Z")!, duration: 1.hours),
            TimePeriod(start: DateInRegion("2019-08-23T05:00:55Z")!, duration: 1.hours),
            TimePeriod(start: DateInRegion("2019-08-24T05:00:55Z")!, duration: 1.hours),
        ]
        
        // create contentview
        let contentView = Timesheet(data: data)
        
        view.addSubview(contentView)
        
        let safeArea = view.safeAreaLayoutGuide
        
        // lay it out
        contentView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        
        contentView.createViews(view: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
