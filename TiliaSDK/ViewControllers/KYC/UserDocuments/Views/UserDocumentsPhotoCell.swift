//
//  UserDocumentsPhotoCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.05.2022.
//

import UIKit

final class UserDocumentsPhotoCell: UITableViewCell {
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 14)
    label.textColor = .primaryTextColor
    return label
  }()
  
  private let photoImageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()
  
  private let primaryButton: PrimaryButtonWithStyle = {
    let button = PrimaryButtonWithStyle(style: .imageAndTitleCenter)
    button.setImage(.cameraIcon?.withRenderingMode(.alwaysTemplate),
                    for: .normal)
    button.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
    return button
  }()
  
  private let nonPrimaryButton: NonPrimaryButtonWithStyle = {
    let button = NonPrimaryButtonWithStyle(style: .imageAndTitleCenter)
    button.setImage(.documentIcon?.withRenderingMode(.alwaysTemplate),
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
  
  func configure(title: String?,
                 image: UIImage?,
                 primaryButtonTitle: String?,
                 nonPrimaryButtonTitle: String) {
    titleLabel.text = title
    titleLabel.isHidden = title == nil
    photoImageView.image = image
    primaryButton.setTitle(primaryButtonTitle, for: .normal)
    primaryButton.imageEdgeInsets.left = primaryButtonTitle == nil ? 0 : -8
    nonPrimaryButton.setTitle(nonPrimaryButtonTitle, for: .normal)
  }
  
}

// MARK: - Private Methods

private extension UserDocumentsPhotoCell {
  
  func setup() {
    selectionStyle = .none
    backgroundColor = .backgroundColor
    contentView.backgroundColor = .backgroundColor
    
    let buttonsStackView = UIStackView(arrangedSubviews: [primaryButton,
                                                          nonPrimaryButton])
    buttonsStackView.spacing = 8
    
    let stackView = UIStackView(arrangedSubviews: [titleLabel,
                                                   photoImageView,
                                                   buttonsStackView])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 16
    stackView.setCustomSpacing(10, after: titleLabel)
    stackView.axis = .vertical
    contentView.addSubview(stackView)
    
    let bottomAnchor = stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
    bottomAnchor.priority = UILayoutPriority(999)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
      bottomAnchor,
      photoImageView.heightAnchor.constraint(equalTo: photoImageView.widthAnchor, multiplier: 0.65)
    ])
  }
  
}
