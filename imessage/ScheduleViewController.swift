import Foundation
import UIKit
import SwiftDate
import Engine

final class ScheduleViewController: UITableViewController {
    
    // The next button on the nav bar
    private var nextButton: UIBarButtonItem!
    
    // The total count of rows tapped; for tracking next button state
    private var _taps: UInt8 = 0
    
    var selectedService: Service? = nil
    
    var model: ScheduleService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Scheduling"
        
        // Setting up nav bar item
        nextButton = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(didTapNextButton))
        nextButton.isEnabled = false
        
        navigationItem.rightBarButtonItem = nextButton
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            model.remove(withTag: "morning")
            model.remove(withTag: "evening")
            model.remove(withTag: "afternoon")
        }
    }
    
    // MARK: Actions
    
    @objc func didTapNextButton() {
        let destination = storyboard!.instantiateViewController(withIdentifier: "AvailabilityVC") as! AvailabilityViewController
        
        destination.model = model
        destination.selectedService = selectedService

        navigationController?.pushViewController(destination, animated: true)
    }
    
    // basic fix
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _taps += 1
        
        switch indexPath.row {
        case 0:  // earliest
            break
        case 1:  // morning
            model.min(only: (start: 0, end: 12), tag: "morning")
            break
        case 2:  // afternoon
            model.min(only: (start: 13, end: 17), tag: "afternoon")
            break
        default:  // evening
            model.min(only: (start: 17, end: 24), tag: "evening")
            break
        }
        
        if _taps == 0 {
            nextButton.isEnabled = false
        } else {
            nextButton.isEnabled = true
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        _taps -= 1
        
        switch indexPath.row {
        case 0:  // earliest
            break
        case 1:  // morning
            model.remove(withTag: "morning")
            break
        case 2:  // afternoon
            model.remove(withTag: "afternoon")
            break
        default:  // evening
            model.remove(withTag: "evening")
            break
        }
        
        if _taps == 0 {
            nextButton.isEnabled = false
        } else {
            nextButton.isEnabled = true
        }
    }
}
