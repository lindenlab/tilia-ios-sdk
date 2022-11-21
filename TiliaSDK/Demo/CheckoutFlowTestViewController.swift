//
//  CheckoutFlowTestViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import UIKit

final class CheckoutFlowTestViewController: TestViewController {
  
  let invoiceIdTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.placeholder = "Authorized invoice id"
    textField.accessibilityIdentifier = "invoiceIdTextField"
    return textField
  }()
  
  let onCompleteLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.text = "onComplete callback will be here"
    return label
  }()
  
  let onErrorLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.text = "onError callback will be here"
    return label
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    invoiceIdTextField.delegate = self
    label.text = "onUpdate callback will be here"
    button.setTitle("Run Checkout flow", for: .normal)
    stackView.insertArrangedSubview(invoiceIdTextField, at: 1)
    stackView.addArrangedSubview(onCompleteLabel)
    stackView.addArrangedSubview(onErrorLabel)
  }
  
  override func buttonTapped() {
    manager.setToken(accessTokenTextField.text ?? "")
    manager.presentCheckoutViewController(on: self,
                                          withInvoiceId: invoiceIdTextField.text ?? "",
                                          animated: true) {
      self.label.attributedText = Self.attributedString(text: "onUpdate callback",
                                                        message: $0.description)
    } onComplete: {
      self.onCompleteLabel.attributedText = Self.attributedString(text: "onComplete callback",
                                                                  message: $0.description)
    } onError: {
      self.onErrorLabel.attributedText = Self.attributedString(text: "onError callback",
                                                               message: $0.description)
    }
  }
  
}
