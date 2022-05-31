//
//  UserDocumentsSelectDocumentCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 26.05.2022.
//

import UIKit

protocol UserDocumentsSelectDocumentCellDelegate: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func userDocumentsSelectDocumentCellAddButtonDidTap(_ cell: UserDocumentsSelectDocumentCell)
}

final class UserDocumentsSelectDocumentCell: LabelCell {
  
  private weak var delegate: UserDocumentsSelectDocumentCellDelegate?
  
  private let addButton: NonPrimaryButtonWithStyle = {
    let button = NonPrimaryButtonWithStyle(style: .imageAndTitleCenter)
    button.setTitle(L.addDocument, for: .normal)
    button.setImage(.addIcon?.withRenderingMode(.alwaysTemplate),
                    for: .normal)
    return button
  }()
  
  private let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 8
    layout.minimumInteritemSpacing = 8
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .backgroundColor
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.register(UserDocumentsDocumentCell.self)
    collectionView.isHidden = true
    return collectionView
  }()
  
  private lazy var collectionViewHeightConstraint: NSLayoutConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(delegate: UserDocumentsSelectDocumentCellDelegate?) {
    self.delegate = delegate
    collectionView.delegate = delegate
    collectionView.dataSource = delegate
  }
  
}

// MARK: - Private Methods

private extension UserDocumentsSelectDocumentCell {
  
  func setup() {
    addButton.addTarget(self, action: #selector(addButtonDidTap), for: .touchUpInside)
    addChildView(addButton)
    addChildView(collectionView)
  }
  
  @objc func addButtonDidTap() {
    delegate?.userDocumentsSelectDocumentCellAddButtonDidTap(self)
  }
  
}
