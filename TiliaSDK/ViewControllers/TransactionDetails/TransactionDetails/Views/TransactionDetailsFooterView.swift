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
  
  private let buttonsView: ButtonsView<PrimaryButtonWithStyle, NonPrimaryButton> = {
    let primaryButton = PrimaryButtonWithStyle(style: .titleAndImageCenter)
    primaryButton.setTitle(L.emailReceipt,
                           for: .normal)
    primaryButton.setImage(.envelopeIcon?.withRenderingMode(.alwaysTemplate),
                           for: .normal)
    primaryButton.accessibilityIdentifier = "emailReceiptButton"
    
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
  
  func configure(isPrimaryButtonHidden: Bool) {
    buttonsView.primaryButton.isEnabled = isPrimaryButtonHidden
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
    
    let rightConstraint = buttonsView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
    rightConstraint.priority = UILayoutPriority(999)
    
    NSLayoutConstraint.activate([
      topConstraint,
      rightConstraint,
      buttonsView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
      buttonsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      divider.topAnchor.constraint(equalTo: topAnchor),
      divider.leftAnchor.constraint(equalTo: leftAnchor),
      divider.rightAnchor.constraint(equalTo: rightAnchor)
    ])
  }
  
}
