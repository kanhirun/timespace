import UIKit
import SwiftDate

class DateTimeViewController: UIViewController {
    
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
        guard data.count > 0 else {
            return
        }

        // Defines the root stackview
        let root = UIStackView(frame: CGRect.zero)
        root.axis = .horizontal
        root.alignment = .top
        root.distribution = .fill

        // Inserts it
        view.addSubview(root)

        // Lays out the view
        let safeArea = view.safeAreaLayoutGuide
        root.translatesAutoresizingMaskIntoConstraints = false
        root.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 0).isActive = true
        root.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor, constant: 0).isActive = true

        // Adds column
        let columnView = UIStackView(frame: CGRect.zero)
        columnView.axis = .vertical
        columnView.alignment = .fill
        columnView.distribution = .fill
        // Day header
        let dayHeader = UINib(nibName: "DateCell", bundle: Bundle.main)
            .instantiate(withOwner: self, options: nil)
            .first! as! UIView
        columnView.addArrangedSubview(dayHeader)

        // Lay it out
        columnView.translatesAutoresizingMaskIntoConstraints = false
        columnView.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.33).isActive = true

        // Add it
        root.addArrangedSubview(columnView)

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
