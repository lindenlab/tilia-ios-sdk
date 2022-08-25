//
//  UserInfoFooterView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 07.05.2022.
//

import UIKit

final class UserInfoFooterView: UITableViewHeaderFooterView {
  
  private let divider: DividerView = {
    let view = DividerView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let buttonsView: ButtonsView<PrimaryButton, NonPrimaryButton> = {
    let primaryButton = PrimaryButton(style: .titleAndImageCenter)
    primaryButton.setTitle(L.continueTitle,
                           for: .normal)
    primaryButton.setImage(.arrowRightIcon?.withRenderingMode(.alwaysTemplate),
                           for: .normal)
    primaryButton.accessibilityIdentifier = "continueButton"
    
    let nonPrimaryButton = NonPrimaryButton()
    nonPrimaryButton.setTitle(L.cancel,
                              for: .normal)
    
    let view = ButtonsView(primaryButton: primaryButton,
                           nonPrimaryButton: nonPrimaryButton,
                           insets: .init(top: 24, left: 16, bottom: 16, right: 16))
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  func configure(delegate: ButtonsViewDelegate?) {
    buttonsView.delegate = delegate
  }
  
  func configure(isPrimaryButtonEnabled: Bool) {
    buttonsView.primaryButton.isEnabled = isPrimaryButtonEnabled
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
    contentView.backgroundColor = .backgroundColor
    contentView.addSubview(buttonsView)
    contentView.addSubview(divider)
    
    let topConstraint = buttonsView.topAnchor.constraint(equalTo: contentView.topAnchor)
    topConstraint.priority = UILayoutPriority(999)
    
    NSLayoutConstraint.activate([
      topConstraint,
      buttonsView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
      buttonsView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
      buttonsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      divider.topAnchor.constraint(equalTo: contentView.topAnchor),
      divider.leftAnchor.constraint(equalTo: contentView.leftAnchor),
      divider.rightAnchor.constraint(equalTo: contentView.rightAnchor)
    ])
  }
  
}
