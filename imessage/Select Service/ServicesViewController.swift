import Foundation
import UIKit
import SwiftDate
import Engine
import Messages

final class ServicesViewController: UITableViewController {

    let model = ServiceViewModel()
    var activeConversation: MSConversation? = nil
    weak var actionDelegate: ActionDelegate?
    
    // MARK: - Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Services"
        tableView.dataSource = self
        tableView.sizeToFit()

        model.requestAccess()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // User hits "Back" button
        if self.isMovingFromParent {
            model.unselect()
        }
    }

    // MARK: - Actions
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dest = UIStoryboard(name: "Calendar", bundle: Bundle.main).instantiateInitialViewController()!
            as! PickCalendarDatesViewController

        model.select(indexPath.row)

        dest.conversation = activeConversation
        dest.viewModel = PickCalendarDatesViewModel(
            serviceRepository: ServiceRepository.shared,
            scheduleService: model.scheduleService,
            conversation: activeConversation!
        )
        dest.actionDelegate = actionDelegate

        navigationController?.pushViewController(dest, animated: true)
    }
    
    // MARK: - Service Cell Appearance
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell")! as! ServiceCell
        cell.updateUI(model.services[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.services.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}
