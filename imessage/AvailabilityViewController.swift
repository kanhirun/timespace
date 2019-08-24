import Foundation
import UIKit
import SwiftDate
import Engine
import Alamofire

class AvailabilityViewController: UICollectionViewController {
    
    @IBOutlet weak var availabilityView: UICollectionView!

    var selectedService: Service!
    var model: TimePeriodFilter!
    var results: [TimePeriod]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Availability"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let appleCalendar = AppleCalendar()
        appleCalendar.requestAccess()

        model.subtract(fromSource: appleCalendar, tag: title!, completion: { result in
            switch result {
            case .success(_):
                self.results = self.model
                    .quantize(unit: self.selectedService!.duration, tag: self.title!)
                    .apply(region: Region.local)
                self.availabilityView.reloadData()
            case .failure(let err):
                debugPrint(err)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            model.remove(withTag: title!)
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let results = results else {
            return UICollectionViewCell(frame: CGRect.zero)
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvailabilityCell", for: indexPath) as! AvailabilityCell
        
        let start = results[indexPath.row].start
        let end = results[indexPath.row].end
        
        cell.monthLabel.text = "\(start!.monthName(.short)) \(start!.day)"
        cell.timePeriodLabel.text = "\(start!.toFormat("h:mma")) - \(end!.toFormat("h:mma"))"
        cell.weekdayLabel.text = start?.weekdayName(.default)
        
        return cell
    }
}

