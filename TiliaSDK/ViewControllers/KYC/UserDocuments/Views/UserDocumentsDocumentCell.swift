//
//  UserDocumentsDocumentCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 31.05.2022.
//

import UIKit

protocol UserDocumentsDocumentCellDelegate: AnyObject {
  func userDocumentsDocumentCellDeleteButtonDidTap(_ cell: UserDocumentsDocumentCell)
}

final class UserDocumentsDocumentCell: UICollectionViewCell {
  
  private weak var delegate: UserDocumentsDocumentCellDelegate?
  
  private let imageView: UIImageView = {
    let view = UIImageView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.contentMode = .scaleAspectFit
    return view
  }()
  
  private let deleteButton: PrimaryButton = {
    let button = PrimaryButton()
    button.adjustsImageWhenHighlighted = false
    button.setImage(.closeIcon?.withRenderingMode(.alwaysTemplate),
                    for: .normal)
    button.imageView?.tintColor = .primaryButtonTextColor
    button.translatesAutoresizingMaskIntoConstraints = false
    button.layer.cornerRadius = 20
    return button
  }()
  
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
    guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
    setupBorderColor()
  }
  
  func configure(image: UIImage?,
                 delegate: UserDocumentsDocumentCellDelegate?) {
    imageView.image = image
    self.delegate = delegate
  }
  
}

// MARK: - Private Methods

private extension UserDocumentsDocumentCell {
  
  func setup() {
    backgroundColor = .backgroundColor
    contentView.clipsToBounds = true
    contentView.backgroundColor = .backgroundColor
    contentView.layer.cornerRadius = 8
    contentView.layer.borderWidth = 1
    contentView.addSubview(imageView)
    contentView.addSubview(deleteButton)
    
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 8
    
    deleteButton.addTarget(self, action: #selector(deleteButtonDidTap), for: .touchUpInside)
    
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
      imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 1),
      imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -1),
      imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1),
      deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      deleteButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
      deleteButton.widthAnchor.constraint(equalToConstant: 40),
      deleteButton.heightAnchor.constraint(equalToConstant: 40)
    ])
  }
  
  func setupBorderColor() {
    contentView.layer.borderColor = UIColor.borderColor.cgColor
  }
  
  @objc func deleteButtonDidTap() {
    delegate?.userDocumentsDocumentCellDeleteButtonDidTap(self)
  }
  
}
