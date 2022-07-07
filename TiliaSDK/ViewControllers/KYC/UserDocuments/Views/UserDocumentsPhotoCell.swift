//
//  UserDocumentsPhotoCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.05.2022.
//

import UIKit

protocol UserDocumentsPhotoCellDelegate: AnyObject {
  func userDocumentsPhotoCellPrimaryButtonDidTap(_ cell: UserDocumentsPhotoCell)
  func userDocumentsPhotoCellNonPrimaryButtonDidTap(_ cell: UserDocumentsPhotoCell)
}

final class UserDocumentsPhotoCell: TitleBaseCell {
  
  private weak var delegate: UserDocumentsPhotoCellDelegate?
  
  private let photoImageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()
  
  private let primaryButton: PrimaryButtonWithStyle = {
    let button = PrimaryButtonWithStyle(style: .imageAndTitleCenter)
    button.setImage(.cameraIcon?.withRenderingMode(.alwaysTemplate),
                    for: .normal)
    button.setTitle(L.capture, for: .normal)
    return button
  }()
  
  private let nonPrimaryButton: NonPrimaryButtonWithStyle = {
    let button = NonPrimaryButtonWithStyle(style: .imageAndTitleCenter)
    button.setImage(.documentIcon?.withRenderingMode(.alwaysTemplate),
                    for: .normal)
    button.setTitle(L.choose, for: .normal)
    return button
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(delegate: UserDocumentsPhotoCellDelegate?) {
    self.delegate = delegate
  }
  
  func configure(image: UIImage?) {
    photoImageView.image = image
  }
  
}

// MARK: - Private Methods

private extension UserDocumentsPhotoCell {
  
  func setup() {
    selectionStyle = .none
    backgroundColor = .backgroundColor
    contentView.backgroundColor = .backgroundColor
    
    primaryButton.addTarget(self, action: #selector(primaryButtonDidTap), for: .touchUpInside)
    nonPrimaryButton.addTarget(self, action: #selector(nonPrimaryButtonDidTap), for: .touchUpInside)
    
    let buttonsStackView = UIStackView(arrangedSubviews: [primaryButton,
                                                          nonPrimaryButton])
    buttonsStackView.spacing = 8
    buttonsStackView.distribution = .fillEqually
    
    addChildView(photoImageView, spacing: 16)
    addChildView(buttonsStackView)
    
    NSLayoutConstraint.activate([
      photoImageView.heightAnchor.constraint(equalTo: photoImageView.widthAnchor, multiplier: 0.65)
    ])
  }
  
  @objc func primaryButtonDidTap() {
    delegate?.userDocumentsPhotoCellPrimaryButtonDidTap(self)
  }
  
  @objc func nonPrimaryButtonDidTap() {
    delegate?.userDocumentsPhotoCellNonPrimaryButtonDidTap(self)
  }
  
}