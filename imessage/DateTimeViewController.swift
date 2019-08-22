import UIKit
import SwiftDate

class DateTimeViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let data = [TimePeriod]()
        createViews(data)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Private
    
    // FYI: we assume data is sorted
    private func createViews(_ data: [TimePeriod]) {
//        guard data.count > 0 else {
//            return
//        }
        
        let view = Bundle.main.loadNibNamed("DateCell", owner: nil, options: nil)!.first! as! UIView

        // Inserts it
        contentView.addArrangedSubview(view)
        
//        rootView.addArrangedSubview(square)
//
//        // Adds column
//        let columnView = UIStackView(frame: CGRect.zero)
//        columnView.axis = .vertical
//        columnView.alignment = .fill
//        columnView.distribution = .fill
//        // Day header
//        let xib = XibView(frame: CGRect.zero)
//        xib.nibName = "DateCell"
//        xib.xibSetup()
//        let view = xib.contentView!
//        view.translatesAutoresizingMaskIntoConstraints = false
//        columnView.addArrangedSubview(view)
//
//        // Lay it out
//        columnView.translatesAutoresizingMaskIntoConstraints = false
//        columnView.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.33).isActive = true
//
//        // Add it
//        root.addArrangedSubview(columnView)

//        data.forEach { period in
//            // New column should be created
//            if (curr == nil || period.start!.day > curr! ) {.
//                // Create day header
//                // Add time period
//
//                curr = period.start?.day
//            // Current column should be appended
//            } else {
//                // Add time period to curr column
//            }
//        }

    }
}
