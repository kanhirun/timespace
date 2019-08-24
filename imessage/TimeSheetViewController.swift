import UIKit
import SwiftDate

class TimeSheetViewController: UIViewController {
    
    var contentView: TimeSheetView? = nil
    var data: [TimePeriod]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Define
        contentView = TimeSheetView(periods: data, controller: self)

        // Add
        view.addSubview(contentView!)
        
        // Layout
        let safeArea = view.safeAreaLayoutGuide
        contentView!.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        contentView!.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Actions
    
    func selectAppointment(period: TimePeriod) {
        print(period)
        
        // navigation to confirmation screen
        // pass along period and service
    }
}
