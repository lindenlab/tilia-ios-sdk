//
//  UserInfoUpdateEmailCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.05.2023.
//

import UIKit

protocol UserInfoUpdateEmailCellDelegate: AnyObject {
  func userInfoUpdateEmailCellUpdateButtonDidTap(_ cell: UserInfoUpdateEmailCell)
  func userInfoUpdateEmailCellCancelButtonDidTap(_ cell: UserInfoUpdateEmailCell)
}

final class UserInfoUpdateEmailCell: UITableViewCell {
  
  private weak var delegate: UserInfoUpdateEmailCellDelegate?
  
  private let cancelButton: NonPrimaryButton = {
    let button = NonPrimaryButton(style: .titleAndImageCenter)
    button.setTitle(L.cancel, for: .normal)
    return button
  }()
  
  private lazy var updateButton: PrimaryButton = {
    let button = PrimaryButton(style: .titleAndImageCenter)
    button.setTitle(L.updateEmail, for: .normal)
    button.setImage(.arrowRightIcon?.withRenderingMode(.alwaysTemplate),
                    for: .normal)
    return button
  }()
  
  func configure(delegate: UserInfoUpdateEmailCellDelegate?) {
    self.delegate = delegate
  }
  
  func configure(isUpdateButtonEnabled: Bool) {
    updateButton.isEnabled = isUpdateButtonEnabled
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Private Methods

private extension UserInfoUpdateEmailCell {
  
  func setup() {
    selectionStyle = .none
    backgroundColor = .backgroundColor
    contentView.backgroundColor = .backgroundColor
    
    let stackView = UIStackView(arrangedSubviews: [cancelButton, updateButton])
    stackView.spacing = 8
    stackView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(stackView)
    
    cancelButton.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
    updateButton.addTarget(self, action: #selector(updateButtonDidTap), for: .touchUpInside)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
      stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
    ])
  }
  
  @objc func cancelButtonDidTap() {
    delegate?.userInfoUpdateEmailCellCancelButtonDidTap(self)
  }
  
  @objc func updateButtonDidTap() {
    delegate?.userInfoUpdateEmailCellUpdateButtonDidTap(self)
  }
  
}
