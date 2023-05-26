//
//  PaymentSelectionFlowTestViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.05.2023.
//

import UIKit

final class PaymentSelectionFlowTestViewController: TestViewController {
  
  let amountTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.placeholder = "Amount (optional)"
    textField.accessibilityIdentifier = "amountTextField"
    return textField
  }()
  
  let currencyTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.placeholder = "Currency code (optional)"
    textField.accessibilityIdentifier = "currencyTextField"
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
    currencyTextField.delegate = self
    label.text = "onUpdate callback will be here"
    button.setTitle("Run Payment Selection flow", for: .normal)
    stackView.insertArrangedSubview(amountTextField, at: 1)
    stackView.insertArrangedSubview(currencyTextField, at: 2)
    stackView.addArrangedSubview(onErrorLabel)
  }
  
  override func buttonTapped() {
    manager.setToken(accessTokenTextField.text ?? "")
    manager.presentPaymentSelectionViewController(on: self,
                                                  withAmount: Double(amountTextField.text ?? ""),
                                                  andCurrencyCode: currencyTextField.text,
                                                  animated: true) {
      self.label.attributedText = Self.attributedString(text: "onUpdate callback",
                                                        message: $0.description)
    } onComplete: {
      self.onErrorLabel.attributedText = Self.attributedString(text: "onComplete callback",
                                                               message: $0.description)
    } onError: {
      self.onErrorLabel.attributedText = Self.attributedString(text: "onError callback",
                                                               message: $0.description)
    }
  }
  
}
