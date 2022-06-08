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
  
  private let buttonsView: ButtonsView<PrimaryButtonWithStyle, NonPrimaryButton> = {
    let primaryButton = PrimaryButtonWithStyle(style: .titleAndImageCenter)
    primaryButton.setTitleForLoadingState(L.hangTight)
    primaryButton.setTitle(L.continueTitle,
                           for: .normal)
    primaryButton.setImage(.rightArrowIcon?.withRenderingMode(.alwaysTemplate),
                           for: .normal)
    
    let nonPrimaryButton = NonPrimaryButton()
    nonPrimaryButton.setTitle(L.cancel,
                              for: .normal)
    
    let view = ButtonsView(primaryButton: primaryButton,
                           nonPrimaryButton: nonPrimaryButton)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  func configure(delegate: ButtonsViewDelegate?) {
    buttonsView.delegate = delegate
  }
  
  func configure(isPrimaryButtonEnabled: Bool) {
    buttonsView.primaryButton.isEnabled = isPrimaryButtonEnabled
  }
  
  func configure(isLoading: Bool) {
    buttonsView.primaryButton.isLoading = isLoading
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
    
    let topConstraint = buttonsView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24)
    topConstraint.priority = UILayoutPriority(999)
    
    let rightConstraint = buttonsView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
    rightConstraint.priority = UILayoutPriority(999)
    
    NSLayoutConstraint.activate([
      topConstraint,
      rightConstraint,
      buttonsView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      buttonsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
      divider.topAnchor.constraint(equalTo: topAnchor),
      divider.leftAnchor.constraint(equalTo: leftAnchor),
      divider.rightAnchor.constraint(equalTo: rightAnchor)
    ])
  }
  
}
