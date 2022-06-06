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
  func userDocumentsSelectDocumentCellCollectionViewDidChangeHeight(_ cell: UserDocumentsSelectDocumentCell)
}

final class UserDocumentsSelectDocumentCell: LabelCell {
    
  private weak var delegate: UserDocumentsSelectDocumentCellDelegate?
  private var documentImages: [UIImage] = []
  
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
  
  func configure(documentImages: [UIImage],
                 delegate: UserDocumentsSelectDocumentCellDelegate?) {
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
      self.setupCollectionViewHeightConstraintIfNeeded()
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
    addButton.addTarget(self, action: #selector(addButtonDidTap), for: .touchUpInside)
    addChildView(addButton)
    addChildView(collectionView)
    collectionViewHeightConstraint.isActive = true
  }
  
  @objc func addButtonDidTap() {
    delegate?.userDocumentsSelectDocumentCellAddButtonDidTap(self)
  }
  
  func setupCollectionViewHeightConstraintIfNeeded() {
    guard !documentImages.isEmpty else {
      if !collectionView.isHidden {
        collectionView.isHidden = true
        collectionViewHeightConstraint.constant = 0
        delegate?.userDocumentsSelectDocumentCellCollectionViewDidChangeHeight(self)
      }
      return
    }
    collectionView.isHidden = false
    let rowCount = CGFloat(Double(documentImages.count) / 2.0).rounded(.up)
    let itemHeight = collectionViewItemSize.height
    let collectionViewHeight = itemHeight * rowCount + (rowCount - 1) * 8
    if collectionViewHeightConstraint.constant != collectionViewHeight {
      collectionViewHeightConstraint.constant = collectionViewHeight
      delegate?.userDocumentsSelectDocumentCellCollectionViewDidChangeHeight(self)
    }
  }
  
}
