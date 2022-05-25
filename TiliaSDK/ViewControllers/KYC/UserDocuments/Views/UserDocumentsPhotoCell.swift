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

final class UserDocumentsPhotoCell: UITableViewCell {
  
  private weak var delegate: UserDocumentsPhotoCellDelegate?
  
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
    button.setTitle(L.captureOnCamera, for: .normal)
    return button
  }()
  
  private let nonPrimaryButton: NonPrimaryButtonWithStyle = {
    let button = NonPrimaryButtonWithStyle(style: .imageAndTitleCenter)
    button.setImage(.documentIcon?.withRenderingMode(.alwaysTemplate),
                    for: .normal)
    button.setTitle(L.pickFile, for: .normal)
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
                 delegate: UserDocumentsPhotoCellDelegate?) {
    titleLabel.text = title
    titleLabel.isHidden = title == nil
    self.delegate = delegate
    configure(image: image)
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
  
  @objc func primaryButtonDidTap() {
    delegate?.userDocumentsPhotoCellPrimaryButtonDidTap(self)
  }
  
  @objc func nonPrimaryButtonDidTap() {
    delegate?.userDocumentsPhotoCellNonPrimaryButtonDidTap(self)
  }
  
}
