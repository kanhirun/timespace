import UIKit
import SwiftDate

protocol TimeSheetCollectionViewDelegate {
    func didAction()
}


// MARK: - Collection View


class TimeSheetCollectionViewV2: UICollectionView {

    var actionDelegate: TimeSheetCollectionViewDelegate?
    
    var viewModel = ViewModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        dataSource = self
        
        showsVerticalScrollIndicator = false
        makeStickyHeaders()
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
    
    private func makeStickyHeaders() {
        let layout = collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
    }
}


// MARK: - Data Source


extension TimeSheetCollectionViewV2: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeSheetCollectionViewCell",
                                                      for: indexPath) as! TimeSheetCollectionViewCell

        cell.delegate = actionDelegate
        cell.viewModel = viewModel.cellViewModels[indexPath.row]

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "TimeSheetHeaderView", for: indexPath
                ) as! TimeSheetHeaderView
            
            header.subHeaderViewModels = viewModel.subHeaderViewModels
            
            return header
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
    }
}


// MARK: - Header View


class TimeSheetHeaderView: UICollectionReusableView {
    
    static let fixedHeaderHeight: CGFloat = 62
    static let widthRatio: CGFloat = 0.3
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var subHeadersView: UIStackView!
    
    var subHeaderViewModels: [HeaderViewModel]? {
        didSet {
            installSubHeaders()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        subHeadersView.arrangedSubviews.forEach { view in
            let widthRatio = TimeSheetHeaderView.widthRatio
            view.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: widthRatio).isActive = true
        }
    }
    
    private func installSubHeaders() {
        subHeaderViewModels?.forEach { headerVM in
            let subHeaderView: DateCell = .fromNib()

            subHeaderView.viewModel = headerVM

            self.subHeadersView.addArrangedSubview(subHeaderView)
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
        delegate?.didAction()
    }
}

class TimeButtonV2: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    }
}
