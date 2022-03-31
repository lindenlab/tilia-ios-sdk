//
//  CheckoutPayloadActionsFooterView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 31.03.2022.
//

import UIKit

protocol CheckoutPayloadActionsFooterViewDelegate: AnyObject {
  func checkoutPayloadActionsFooterViewFullFilledButtonDidTap(_ footerView: CheckoutPayloadActionsFooterView)
  func checkoutPayloadActionsFooterViewRoundedButtonDidTap(_ footerView: CheckoutPayloadActionsFooterView)
}

final class CheckoutPayloadActionsFooterView: UITableViewHeaderFooterView {
  
  private weak var delegate: CheckoutPayloadActionsFooterViewDelegate?
  
  private lazy var fullFilledButton: FullFilledButton = {
    let button = FullFilledButton()
    button.setTitle(L.pay, for: .normal)
    button.addTarget(self, action: #selector(fullFilledButtonDidTap), for: .touchUpInside)
    return button
  }()
  
  private lazy var roundedButton: RoundedButton = {
    let button = RoundedButton()
    button.addTarget(self, action: #selector(roundedButtonDidTap), for: .touchUpInside)
    return button
  }()
  
  private let textView: TextViewWithLink = {
    let textView = TextViewWithLink()
    let text = TosAcceptModel.payTitle
    let links = [TosAcceptModel.termsOfService.description]
    textView.textData = (text, links)
    textView.linkColor = .grayWithMediumTransparency
    textView.textColor = .grayWithMediumTransparency
    textView.font = UIFont.systemFont(ofSize: 12)
    textView.textAlignment = .justified
    return textView
  }()
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(roundedButtonTitle: String,
                 isTextViewHidden: Bool,
                 delegate: CheckoutPayloadActionsFooterViewDelegate?,
                 textViewDelegate: TextViewWithLinkDelegate?) {
    roundedButton.setTitle(roundedButtonTitle, for: .normal)
    textView.isHidden = isTextViewHidden
    textView.linkDelegate = textViewDelegate
    self.delegate = delegate
  }
  
}

// MARK: - Private Methods

private extension CheckoutPayloadActionsFooterView {
  
  func setup() {
    let stackView = UIStackView(arrangedSubviews: [fullFilledButton, roundedButton, textView])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.spacing = 16
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
  
  @objc func fullFilledButtonDidTap() {
    
  }
  
  @objc func roundedButtonDidTap() {
    
  }
  
}
