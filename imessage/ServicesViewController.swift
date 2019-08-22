import Foundation
import UIKit
import SwiftDate
import Engine
import Messages

final class ServicesViewController: UITableViewController {

    let model = ServiceViewModel()
    var activeConversation: MSConversation? = nil
    
    // MARK: - Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Services"
        tableView.dataSource = self
        tableView.sizeToFit()
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
        let dest = storyboard!.instantiateViewController(withIdentifier: "CalendarViewController")
            as! CalendarViewController

        model.select(indexPath.row)

        dest.activeConversation = activeConversation
        dest.model = CalendarViewModel(from: model)

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
