//
//  PaymentFooterView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 31.03.2022.
//

import UIKit

protocol PaymentFooterViewDelegate: AnyObject {
  func paymentFooterViewPayButtonDidTap(_ footerView: PaymentFooterView)
  func paymentFooterViewCloseButtonDidTap(_ footerView: PaymentFooterView)
  func paymentFooterViewAddPaypalButtonDidTap(_ footerView: PaymentFooterView)
  func paymentFooterViewAddCreditCardButtonDidTap(_ footerView: PaymentFooterView)
}

final class PaymentFooterView: UITableViewHeaderFooterView {
  
  private weak var delegate: PaymentFooterViewDelegate?
  
  private lazy var payButton: PrimaryButton = {
    let button = PrimaryButton()
    button.addTarget(self, action: #selector(payButtonDidTap), for: .touchUpInside)
    button.accessibilityIdentifier = "payButton"
    return button
  }()
  
  private let addPaymentMethodLabel: UILabel = {
    let label = UILabel()
    label.text = L.addPaymentMethodTitle
    label.textColor = .primaryTextColor
    label.font = .systemFont(ofSize: 16)
    return label
  }()
  
  private lazy var addPaypalButton: NonPrimaryButton = {
    let button = NonPrimaryButton(style: .titleAndImageCenter)
    button.setTitle(L.add, for: .normal)
    button.setImage(.payPalIcon, for: .normal)
    button.addTarget(self, action: #selector(addPaypalButtonDidTap), for: .touchUpInside)
    button.accessibilityIdentifier = "addPaypalButton"
    return button
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
    textView.linkColor = .tertiaryTextColor
    textView.textColor = .tertiaryTextColor
    textView.font = .systemFont(ofSize: 12)
    textView.textAlignment = .justified
    return textView
  }()
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [
      payButton,
      addPaymentMethodLabel,
      addPaypalButton,
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
                 areAddPaymentMethodButtonsHidden: Bool,
                 delegate: PaymentFooterViewDelegate?,
                 textViewSubTitle: String?,
                 textViewDelegate: TextViewWithLinkDelegate?) {
    payButton.setTitle(payButtonTitle, for: .normal)
    payButton.isHidden = payButtonTitle == nil
    closeButton.setTitle(closeButtonTitle, for: .normal)
    addPaypalButton.isHidden = areAddPaymentMethodButtonsHidden
    addCreditCardButton.isHidden = areAddPaymentMethodButtonsHidden
    addPaymentMethodLabel.isHidden = areAddPaymentMethodButtonsHidden
    if let textViewSubTitle = textViewSubTitle {
      textView.isHidden = false
      let text = L.paymentAcceptDescription(with: textViewSubTitle)
      let links = [TosAcceptModel.termsOfService.description]
      textView.textData = (text, links)
    } else {
      textView.isHidden = true
      textView.attributedText = nil
    }
    textView.linkDelegate = textViewDelegate
    stackView.setCustomSpacing(areAddPaymentMethodButtonsHidden ? 16 : 32, after: payButton)
    self.delegate = delegate
  }
  
  func configure(isPayButtonEnabled: Bool) {
    payButton.isEnabled = isPayButtonEnabled
  }
  
}

// MARK: - Private Methods

private extension PaymentFooterView {
  
  func setup() {
    contentView.backgroundColor = .backgroundColor
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
    delegate?.paymentFooterViewPayButtonDidTap(self)
  }
  
  @objc func addPaypalButtonDidTap() {
    delegate?.paymentFooterViewAddPaypalButtonDidTap(self)
  }
  
  @objc func addCreditCardButtonDidTap() {
    delegate?.paymentFooterViewAddCreditCardButtonDidTap(self)
  }
  
  @objc func closeButtonDidTap() {
    delegate?.paymentFooterViewCloseButtonDidTap(self)
  }
  
}
