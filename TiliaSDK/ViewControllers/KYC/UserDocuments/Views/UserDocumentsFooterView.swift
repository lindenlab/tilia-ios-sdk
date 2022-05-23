//
//  UserDocumentsFooterView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.05.2022.
//

import UIKit

final class UserDocumentsFooterView: UITableViewHeaderFooterView {
  
  private let buttonsView: ButtonsView<PrimaryButtonWithStyle, NonPrimaryButtonWithStyle> = {
    let primaryButton = PrimaryButtonWithStyle(style: .titleAndImageCenter)
    primaryButton.setTitleForLoadingState(L.uploading)
    primaryButton.setTitle(L.upload,
                           for: .normal)
    primaryButton.setImage(.uploadIcon?.withRenderingMode(.alwaysTemplate),
                           for: .normal)
    
    let nonPrimaryButton = NonPrimaryButtonWithStyle(style: .imageAndTitleCenter)
    nonPrimaryButton.setTitle(L.goBack,
                              for: .normal)
    nonPrimaryButton.setImage(.leftArrowicon?.withRenderingMode(.alwaysTemplate),
                              for: .normal)
    
    let view = ButtonsView(primaryButton: primaryButton,
                           nonPrimaryButton: nonPrimaryButton)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  func configure(isPrimaryButtonEnabled: Bool, delegate: ButtonsViewDelegate?) {
    configure(isPrimaryButtonEnabled: isPrimaryButtonEnabled)
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

private extension UserDocumentsFooterView {
  
  func setup() {
    contentView.backgroundColor = .backgroundColor
    contentView.addSubview(buttonsView)
    
    let topConstraint = buttonsView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24)
    topConstraint.priority = UILayoutPriority(999)
    
    NSLayoutConstraint.activate([
      topConstraint,
      buttonsView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
      buttonsView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      buttonsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
    ])
  }
  
}
