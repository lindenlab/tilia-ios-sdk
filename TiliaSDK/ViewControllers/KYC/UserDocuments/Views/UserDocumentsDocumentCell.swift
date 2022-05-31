//
//  UserDocumentsDocumentCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 31.05.2022.
//

import UIKit

final class UserDocumentsDocumentCell: UICollectionViewCell {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    setupBorderColor()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    setupBorderColor()
  }
  
}

private extension UserDocumentsDocumentCell {
  
  func setup() {
    backgroundColor = .backgroundColor
    contentView.backgroundColor = .backgroundColor
    contentView.layer.cornerRadius = 8
    contentView.layer.borderWidth = 1
  }
  
  func setupBorderColor() {
    contentView.layer.borderColor = UIColor.borderColor.cgColor
  }
  
}
