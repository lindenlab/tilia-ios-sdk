//
//  TransactionDetailsFooterView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 22.08.2022.
//

import UIKit

final class TransactionDetailsFooterView: UITableViewHeaderFooterView {
  
  private let divider: DividerView = {
    let view = DividerView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let buttonsView: ButtonsView<PrimaryButton, NonPrimaryButton> = {
    let primaryButton = PrimaryButton(style: .imageAndTitleCenter)
    primaryButton.setTitle(L.emailReceipt,
                           for: .normal)
    primaryButton.setImage(.envelopeIcon?.withRenderingMode(.alwaysTemplate),
                           for: .normal)
    primaryButton.accessibilityIdentifier = "emailReceiptButton"
    
    let nonPrimaryButton = NonPrimaryButton()
    nonPrimaryButton.setTitle(L.close,
                              for: .normal)
    
    let view = ButtonsView(primaryButton: primaryButton,
                           nonPrimaryButton: nonPrimaryButton,
                           insets: .init(top: 44, left: 16, bottom: 16, right: 16))
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  func configure(isPrimaryButtonHidden: Bool, delegate: ButtonsViewDelegate?) {
    buttonsView.primaryButton.isHidden = isPrimaryButtonHidden
    buttonsView.delegate = delegate
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

private extension TransactionDetailsFooterView {
  
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
      divider.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
      divider.leftAnchor.constraint(equalTo: contentView.leftAnchor),
      divider.rightAnchor.constraint(equalTo: contentView.rightAnchor)
    ])
  }
  
}
