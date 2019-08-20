import Foundation
import UIKit
import SwiftDate
import Engine

final class ServicesViewController: UITableViewController {

    struct Service {
        let name: String
        let duration: DateComponents
    }
    
    struct JeanServices {
        static let models: [Service] = [
            Service(name: "Men's Haircut", duration: 45.minutes),
            Service(name: "Chemical: Color", duration: 2.hours),
            Service(name: "Blowdry", duration: 1.hours + 30.minutes),
            Service(name: "Updo", duration: 1.hours),
        ]
    }

    private let services = JeanServices.models
    private var model: Filters!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Services"
        tableView.dataSource = self
        tableView.sizeToFit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set up for 2 weeks
        model = Filters(start: DateInRegion(Date(), region: Region.local), duration: 2.weeks)
            .min(only: .wednesday, .thursday, .friday, .saturday, .sunday, tag: title!)
            .min(only: (start: 9, end: 17), tag: title!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            model.remove(withTag: title!)
        }
    }

    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "ScheduleVC") as! ScheduleViewController
        
        controller.model = model
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell")!
        let service = services[indexPath.row]
        let durationText = service.duration.timeInterval.toString {
            $0.unitsStyle = .abbreviated
        }
        
        cell.textLabel?.text = service.name
        cell.detailTextLabel?.text = durationText
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // MARK: Extras
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        
    }
    
}
