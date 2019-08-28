import UIKit
import SwiftDate
import Engine

enum ViewAction {
    case booked(service: Service, period: TimePeriod)
}

protocol TimeSheetCollectionViewDelegate {
    func didAction(action: ViewAction)
}


// MARK: - Collection View


class TimeSheetCollectionViewV2: UICollectionView {

    var actionDelegate: TimeSheetCollectionViewDelegate?
    
    var viewModel: ViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dataSource = self
        showsVerticalScrollIndicator = false
        
        collectionViewLayout = TimeSheetLayout()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        // note: superview can be the UISnapshotView when taking screenshotss
        if let superview = superview {
            trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
            leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
            topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        }
    }
}


// MARK: - Data Source


extension TimeSheetCollectionViewV2: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.cellViewModels[section].count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeSheetCollectionViewCell",
                                                      for: indexPath) as! TimeSheetCollectionViewCell

        cell.delegate = actionDelegate
        cell.viewModel = viewModel.cellViewModels[indexPath.section][indexPath.row]

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "\(TimeSheetHeaderView.self)", for: indexPath) as! TimeSheetHeaderView

        header.subHeaderViewModels = viewModel.subHeaderViewModels

        return header
    }
}


// MARK: - Header View


class TimeSheetHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var subHeaderViews: UIStackView!

    var subHeaderViewModels: [HeaderViewModel]? {
        didSet {
            removeExistingViews()
            installSubHeaders()
        }
    }
    
    private func removeExistingViews() {
        subHeaderViews.arrangedSubviews.forEach { view in
            subHeaderViews.removeArrangedSubview(view)
        }
    }
    
    private func installSubHeaders() {
        subHeaderViewModels?.forEach { subHeaderVM in
            let subHeaderView: DateCell = .fromNib()

            subHeaderView.viewModel = subHeaderVM

            self.subHeaderViews.addArrangedSubview(subHeaderView)
        }
    }
}


// MARK: - Cell View


class TimeSheetCollectionViewCell: UICollectionViewCell {

    @IBOutlet var timeButton: UIButton!
    
    var viewModel: CellViewModel? {
        didSet {
            timeButton.setTitle(self.viewModel!.timeText, for: .normal)
        }
    }
    
    var delegate: TimeSheetCollectionViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        timeButton.addTarget(self, action: #selector(didAction), for: .primaryActionTriggered)
    }
    
    @objc func didAction() {
        let service = viewModel!.service
        let period = viewModel!.period

        delegate?.didAction(action: .booked(service: service, period: period))
    }

}

class TimeButtonV2: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 105, height: 60)
    }
}
