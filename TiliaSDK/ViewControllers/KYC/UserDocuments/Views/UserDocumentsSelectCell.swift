//
//  UserDocumentsSelectCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 26.05.2022.
//

import UIKit

protocol UserDocumentsSelectCellDelegate: AnyObject {
  func userDocumentsSelectCellAddButtonDidTap(_ cell: UserDocumentsSelectCell)
}

final class UserDocumentsSelectCell: LabelCell {
  
  private weak var delegate: UserDocumentsSelectCellDelegate?
  
  private let addButton: NonPrimaryButtonWithStyle = {
    let button = NonPrimaryButtonWithStyle(style: .imageAndTitleCenter)
    button.setTitle(L.addDocument, for: .normal)
    button.setImage(.addIcon?.withRenderingMode(.alwaysTemplate),
                    for: .normal)
    return button
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(delegate: UserDocumentsSelectCellDelegate?) {
    self.delegate = delegate
  }
  
}

// MARK: - Private Methods

private extension UserDocumentsSelectCell {
  
  func setup() {
    addButton.addTarget(self, action: #selector(addButtonDidTap), for: .touchUpInside)
    addChildView(addButton)
  }
  
  @objc func addButtonDidTap() {
    delegate?.userDocumentsSelectCellAddButtonDidTap(self)
  }
  
}
