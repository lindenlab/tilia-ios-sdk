//
//  UserInfoNextButtonCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 21.05.2022.
//

import UIKit

protocol UserInfoNextButtonCellDelegate: AnyObject {
  func userInfoNextButtonCellButtonDidTap(_ cell: UserInfoNextButtonCell)
}

final class UserInfoNextButtonCell: UITableViewCell {
  
  private weak var delegate: UserInfoNextButtonCellDelegate?
  
  private let button: NonPrimaryButtonWithStyle = {
    let button = NonPrimaryButtonWithStyle(style: .titleAndImageCenter)
    button.setTitle(L.next,
                    for: .normal)
    button.setImage(.rightArrowIcon?.withRenderingMode(.alwaysTemplate),
                    for: .normal)
    button.setBackgroundColor(.backgroundColor, for: .disabled)
    button.setTitleColor(.borderColor, for: .disabled)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  func configure(delegate: UserInfoNextButtonCellDelegate?) {
    self.delegate = delegate
  }
  
  func configure(isButtonEnabled: Bool) {
    button.isEnabled = isButtonEnabled
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

private extension UserInfoNextButtonCell {
  
  func setup() {
    selectionStyle = .none
    backgroundColor = .backgroundColor
    contentView.backgroundColor = .backgroundColor
    contentView.addSubview(button)
    
    button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
    
    NSLayoutConstraint.activate([
      button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
      button.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
    ])
  }
  
  @objc func buttonDidTap() {
    delegate?.userInfoNextButtonCellButtonDidTap(self)
  }
  
}
