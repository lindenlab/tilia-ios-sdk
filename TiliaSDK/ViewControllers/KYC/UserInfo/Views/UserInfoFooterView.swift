//
//  UserInfoFooterView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 07.05.2022.
//

import UIKit

protocol UserInfoFooterViewDelegate: AnyObject {
  func userInfoFooterViewButtonDidTap(_ footer: UserInfoFooterView)
}

final class UserInfoFooterView: UITableViewHeaderFooterView {
  
  private weak var delegate: UserInfoFooterViewDelegate?
  
  private lazy var button: NonPrimaryButtonWithImage = {
    let button = NonPrimaryButtonWithImage(style: .titleAndImageCenter)
    button.setTitle(L.next,
                    for: .normal)
    button.setImage(.rightArrowIcon?.withRenderingMode(.alwaysTemplate),
                    for: .normal)
    button.setBackgroundColor(.backgroundColor, for: .disabled)
    button.setTitleColor(.borderColor, for: .disabled)
    button.imageView?.tintColor = .primaryTextColor
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
    return button
  }()
  
  func configure(isButtonEnabled: Bool, delegate: UserInfoFooterViewDelegate?) {
    button.isEnabled = isButtonEnabled
    self.delegate = delegate
  }
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Private Methods

private extension UserInfoFooterView {
  
  func setup() {
    contentView.backgroundColor = .clear
    contentView.addSubview(button)
    
    let topConstraint = button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16)
    topConstraint.priority = UILayoutPriority(999)
    NSLayoutConstraint.activate([
      topConstraint,
      button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
      button.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
    ])
  }
  
  @objc func buttonDidTap() {
    delegate?.userInfoFooterViewButtonDidTap(self)
  }
  
}
