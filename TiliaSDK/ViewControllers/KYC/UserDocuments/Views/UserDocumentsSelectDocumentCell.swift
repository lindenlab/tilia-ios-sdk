//
//  UserDocumentsSelectDocumentCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 26.05.2022.
//

import UIKit

protocol UserDocumentsSelectDocumentCellDelegate: AnyObject {
  func userDocumentsSelectDocumentCellAddButtonDidTap(_ cell: UserDocumentsSelectDocumentCell)
  func userDocumentsSelectDocumentCell(_ cell: UserDocumentsSelectDocumentCell, didDeleteItemAt index: Int)
  func userDocumentsSelectDocumentCell(_ cell: UserDocumentsSelectDocumentCell, didChangeCollectionViewHeight animated: Bool)
}

final class UserDocumentsSelectDocumentCell: UITableViewCell {
    
  private weak var delegate: UserDocumentsSelectDocumentCellDelegate?
  private var documentImages: [UIImage] = []
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.textColor = .primaryTextColor
    label.font = .boldSystemFont(ofSize: 16)
    return label
  }()
  
  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.text = L.supportingDocumentsDescription
    label.textColor = .secondaryTextColor
    label.numberOfLines = 0
    label.font = .systemFont(ofSize: 14)
    return label
  }()
  
  private let addButton: NonPrimaryButtonWithStyle = {
    let button = NonPrimaryButtonWithStyle(style: .imageAndTitleCenter)
    button.setTitle(L.addDocument, for: .normal)
    button.setImage(.addIcon?.withRenderingMode(.alwaysTemplate),
                    for: .normal)
    return button
  }()
  
  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 8
    layout.minimumInteritemSpacing = 8
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .backgroundColor
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.register(UserDocumentsDocumentCell.self)
    collectionView.isHidden = true
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.delaysContentTouches = false
    return collectionView
  }()
  
  private lazy var collectionViewWidth: CGFloat = 0
  private var collectionViewItemSize: CGSize {
    let width = (collectionView.frame.width - 9) / 2
    let height = width * 1.3
    return CGSize(width: width, height: height)
  }
  
  private lazy var collectionViewHeightConstraint: NSLayoutConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(title: String,
                 documentImages: [UIImage],
                 delegate: UserDocumentsSelectDocumentCellDelegate?) {
    titleLabel.text = title
    self.documentImages = documentImages
    self.delegate = delegate
    setupCollectionViewHeightConstraintIfNeeded()
    collectionView.reloadData()
  }
  
  func configure(documentImages: [UIImage],
                 insertIndexesRange: ClosedRange<Int>) {
    self.documentImages = documentImages
    setupCollectionViewHeightConstraintIfNeeded()
    let indexPaths = (insertIndexesRange.lowerBound...insertIndexesRange.upperBound).map { IndexPath(item: $0, section: 0) }
    collectionView.insertItems(at: indexPaths)
  }
  
  func configure(documentImages: [UIImage], deleteIndex: Int) {
    self.documentImages = documentImages
    collectionView.performBatchUpdates {
      collectionView.deleteItems(at: [IndexPath(item: deleteIndex, section: 0)])
    } completion: { _ in
      self.setupCollectionViewHeightConstraintIfNeeded(animated: true)
    }
  }
  
}

// MARK: - UICollectionViewDataSource

extension UserDocumentsSelectDocumentCell: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return documentImages.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeue(UserDocumentsDocumentCell.self,
                                      for: indexPath)
    cell.configure(image: documentImages[indexPath.item],
                   delegate: self)
    return cell
  }
  
}

// MARK: - UICollectionViewDelegateFlowLayout

extension UserDocumentsSelectDocumentCell: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return collectionViewItemSize
  }
  
}

// MARK: - UserDocumentsDocumentCellDelegate

extension UserDocumentsSelectDocumentCell: UserDocumentsDocumentCellDelegate {
  
  func userDocumentsDocumentCellDeleteButtonDidTap(_ cell: UserDocumentsDocumentCell) {
    guard let indexPath = collectionView.indexPath(for: cell) else { return }
    delegate?.userDocumentsSelectDocumentCell(self, didDeleteItemAt: indexPath.item)
  }
  
}

// MARK: - Private Methods

private extension UserDocumentsSelectDocumentCell {
  
  func setup() {
    selectionStyle = .none
    backgroundColor = .backgroundColor
    contentView.backgroundColor = .backgroundColor
    
    addButton.addTarget(self, action: #selector(addButtonDidTap), for: .touchUpInside)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(orientationDidChange),
                                           name: UIDevice.orientationDidChangeNotification,
                                           object: nil)
    
    let stackView = UIStackView(arrangedSubviews: [titleLabel,
                                                   descriptionLabel,
                                                   addButton,
                                                   collectionView])
    stackView.axis = .vertical
    stackView.spacing = 8
    stackView.setCustomSpacing(16, after: descriptionLabel)
    
    let rootStackView = UIStackView(arrangedSubviews: [stackView])
    rootStackView.alignment = .top
    rootStackView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(rootStackView)
    
    let bottomAnchor = rootStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
    bottomAnchor.priority = UILayoutPriority(999)
    
    NSLayoutConstraint.activate([
      rootStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      rootStackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      rootStackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
      bottomAnchor,
      collectionViewHeightConstraint
    ])
  }
  
  @objc func addButtonDidTap() {
    delegate?.userDocumentsSelectDocumentCellAddButtonDidTap(self)
  }
  
  func setupCollectionViewHeightConstraintIfNeeded(animated: Bool = false) {
    guard !documentImages.isEmpty else {
      if !collectionView.isHidden {
        collectionView.isHidden = true
        collectionViewHeightConstraint.constant = 0
        delegate?.userDocumentsSelectDocumentCell(self, didChangeCollectionViewHeight: animated)
      }
      return
    }
    collectionView.isHidden = false
    let rowCount = CGFloat(Double(documentImages.count) / 2.0).rounded(.up)
    let itemHeight = collectionViewItemSize.height
    let collectionViewHeight = itemHeight * rowCount + (rowCount - 1) * 8
    if collectionViewHeightConstraint.constant != collectionViewHeight {
      collectionViewHeightConstraint.constant = collectionViewHeight
      delegate?.userDocumentsSelectDocumentCell(self, didChangeCollectionViewHeight: animated)
    }
  }
  
  @objc func orientationDidChange() {
    guard
      !collectionView.isHidden,
      collectionView.frame.width != collectionViewWidth else { return }
    collectionViewWidth = collectionView.frame.width
    collectionView.collectionViewLayout.invalidateLayout()
    setupCollectionViewHeightConstraintIfNeeded()
  }
  
}
