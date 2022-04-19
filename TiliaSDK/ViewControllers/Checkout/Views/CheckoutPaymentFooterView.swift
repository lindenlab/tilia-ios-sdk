//
//  CheckoutPaymentFooterView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 31.03.2022.
//

import UIKit

protocol CheckoutPaymentFooterViewDelegate: AnyObject {
  func checkoutPaymentFooterViewPrimaryButtonDidTap(_ footerView: CheckoutPaymentFooterView)
  func checkoutPaymentFooterViewNonPrimaryButtonDidTap(_ footerView: CheckoutPaymentFooterView)
}

final class CheckoutPaymentFooterView: UITableViewHeaderFooterView {
  
  private weak var delegate: CheckoutPaymentFooterViewDelegate?
  
  private lazy var primaryButton: PrimaryButton = {
    let button = PrimaryButton()
    button.setTitle(L.pay, for: .normal)
    button.addTarget(self, action: #selector(primaryButtonDidTap), for: .touchUpInside)
    button.accessibilityIdentifier = "primaryButton"
    return button
  }()
  
  private lazy var nonPrimaryButton: NonPrimaryButton = {
    let button = NonPrimaryButton()
    button.addTarget(self, action: #selector(nonPrimaryButtonDidTap), for: .touchUpInside)
    button.accessibilityIdentifier = "nonPrimaryButton"
    return button
  }()
  
  private let textView: TextViewWithLink = {
    let textView = TextViewWithLink()
    let text = TosAcceptModel.payTitle
    let links = [TosAcceptModel.termsOfService.description]
    textView.textData = (text, links)
    textView.linkColor = .tertiaryTextColor
    textView.textColor = .tertiaryTextColor
    textView.font = UIFont.systemFont(ofSize: 12)
    textView.textAlignment = .justified
    textView.backgroundColor = .clear
    return textView
  }()
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(nonPrimaryButtonTitle: String,
                 isPrimaryButtonEnabled: Bool,
                 delegate: CheckoutPaymentFooterViewDelegate?,
                 textViewDelegate: TextViewWithLinkDelegate?) {
    nonPrimaryButton.setTitle(nonPrimaryButtonTitle, for: .normal)
    primaryButton.isEnabled = isPrimaryButtonEnabled
    primaryButton.isHidden = textViewDelegate == nil
    textView.isHidden = textViewDelegate == nil
    textView.linkDelegate = textViewDelegate
    self.delegate = delegate
  }
  
  func configure(isPrimaryButtonEnabled: Bool) {
    primaryButton.isEnabled = isPrimaryButtonEnabled
  }
  
}

// MARK: - Private Methods

private extension CheckoutPaymentFooterView {
  
  func setup() {
    let stackView = UIStackView(arrangedSubviews: [primaryButton, nonPrimaryButton, textView])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.spacing = 16
    
    contentView.backgroundColor = .clear
    contentView.addSubview(stackView)
    
    let topConstraint = stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16)
    topConstraint.priority = UILayoutPriority(999)
    NSLayoutConstraint.activate([
      topConstraint,
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
    ])
  }
  
  @objc func primaryButtonDidTap() {
    delegate?.checkoutPaymentFooterViewPrimaryButtonDidTap(self)
  }
  
  @objc func nonPrimaryButtonDidTap() {
    delegate?.checkoutPaymentFooterViewNonPrimaryButtonDidTap(self)
  }
  
}
