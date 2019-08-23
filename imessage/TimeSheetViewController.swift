import UIKit
import SwiftDate

class TimeSheetViewController: UIViewController {
    
    var contentView: TimeSheetView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let data: [TimePeriod] = [
            TimePeriod(start: DateInRegion("2019-08-22T09:00:00Z")!, duration: 1.hours),
            TimePeriod(start: DateInRegion("2019-08-22T16:55:55Z")!, duration: 1.hours),
            TimePeriod(start: DateInRegion("2019-08-22T20:30:55Z")!, duration: 1.hours),
            TimePeriod(start: DateInRegion("2019-08-23T05:00:55Z")!, duration: 1.hours),
            TimePeriod(start: DateInRegion("2019-08-24T05:00:55Z")!, duration: 1.hours),
        ]

        // Define
        contentView = TimeSheetView(periods: data)

        // Add
        view.addSubview(contentView!)
        
        // Layout
        let safeArea = view.safeAreaLayoutGuide
        contentView!.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        contentView!.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
    }
}
