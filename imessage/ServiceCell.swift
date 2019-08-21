import UIKit

class ServiceCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!

    func update(_ service: Service) {
        titleLabel?.text = service.name

        detailTextLabel?.text = service.duration.timeInterval.toString {
            $0.unitsStyle = .abbreviated
        }
    }
}
