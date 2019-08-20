import Foundation
import UIKit
import SwiftDate
import Engine
import Alamofire

class AvailabilityViewController: UICollectionViewController {
    
    @IBOutlet weak var availabilityView: UICollectionView!

    var model: Filters!
    var results: [TimePeriod]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Availability"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let appleCalendar = AppleCalendar()
        appleCalendar.requestAccess()

        model.subtract(
            fromSource: appleCalendar,
            tag: title!,
            onSuccess: {
                self.results = self.model.apply(region: Region.local)
                self.availabilityView.reloadData()
            },
            onFailure: { err in
                debugPrint(err)
            }
        )
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
        cell.timePeriodLabel.text = "\(start!.toFormat("ha")) - \(end!.toFormat("ha")) \(start!.toFormat("z"))"
        cell.weekdayLabel.text = start?.weekdayName(.default)
        
        return cell
    }
}

