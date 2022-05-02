//
//  CheckoutPaymentFooterView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 31.03.2022.
//

import UIKit

protocol CheckoutPaymentFooterViewDelegate: AnyObject {
  func checkoutPaymentFooterViewPayButtonDidTap(_ footerView: CheckoutPaymentFooterView)
  func checkoutPaymentFooterViewCloseButtonDidTap(_ footerView: CheckoutPaymentFooterView)
  func checkoutPaymentFooterViewAddCreditCardButtonDidTap(_ footerView: CheckoutPaymentFooterView)
}

final class CheckoutPaymentFooterView: UITableViewHeaderFooterView {
  
  private weak var delegate: CheckoutPaymentFooterViewDelegate?
  
  private lazy var payButton: PrimaryButton = {
    let button = PrimaryButton()
    button.addTarget(self, action: #selector(payButtonDidTap), for: .touchUpInside)
    button.accessibilityIdentifier = "payButton"
    return button
  }()
  
  private let addPaymentMethodLabel: UILabel = {
    let label = UILabel()
    label.text = L.addPaymentMethodTitle.localized
    label.textColor = .primaryTextColor
    label.font = UIFont.systemFont(ofSize: 16)
    return label
  }()
  
  private lazy var addCreditCardButton: NonPrimaryButton = {
    let button = NonPrimaryButton()
    button.setTitle(L.addCreditCardTitle, for: .normal)
    button.addTarget(self, action: #selector(addCreditCardButtonDidTap), for: .touchUpInside)
    button.accessibilityIdentifier = "addCreditCardButton"
    return button
  }()
  
  private lazy var closeButton: NonPrimaryButton = {
    let button = NonPrimaryButton()
    button.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
    button.accessibilityIdentifier = "closeButton"
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
    return textView
  }()
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [
      payButton,
      addPaymentMethodLabel,
      addCreditCardButton,
      closeButton,
      textView
    ])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.spacing = 16
    return stackView
  }()
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(payButtonTitle: String?,
                 closeButtonTitle: String,
                 isPayButtonEnabled: Bool,
                 isCreditCardButtonHidden: Bool,
                 delegate: CheckoutPaymentFooterViewDelegate?,
                 textViewDelegate: TextViewWithLinkDelegate?) {
    payButton.setTitle(payButtonTitle, for: .normal)
    payButton.isEnabled = isPayButtonEnabled
    payButton.isHidden = payButtonTitle == nil
    closeButton.setTitle(closeButtonTitle, for: .normal)
    addCreditCardButton.isHidden = isCreditCardButtonHidden
    addPaymentMethodLabel.isHidden = isCreditCardButtonHidden
    textView.isHidden = textViewDelegate == nil
    textView.linkDelegate = textViewDelegate
    stackView.setCustomSpacing(isCreditCardButtonHidden ? 16 : 32, after: payButton)
    self.delegate = delegate
  }
  
  func configure(isPrimaryButtonEnabled: Bool) {
    payButton.isEnabled = isPrimaryButtonEnabled
  }
  
}

// MARK: - Private Methods

private extension CheckoutPaymentFooterView {
  
  func setup() {
    contentView.backgroundColor = .clear
    contentView.addSubview(stackView)
    
    let topConstraint = stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16)
    topConstraint.priority = UILayoutPriority(999)
    NSLayoutConstraint.activate([
      topConstraint,
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
      stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
    ])
  }
  
  @objc func payButtonDidTap() {
    delegate?.checkoutPaymentFooterViewPayButtonDidTap(self)
  }
  
  @objc func addCreditCardButtonDidTap() {
    delegate?.checkoutPaymentFooterViewAddCreditCardButtonDidTap(self)
  }
  
  @objc func closeButtonDidTap() {
    delegate?.checkoutPaymentFooterViewCloseButtonDidTap(self)
  }
  
}
