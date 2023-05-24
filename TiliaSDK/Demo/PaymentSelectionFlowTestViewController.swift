//
//  PaymentSelectionFlowTestViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.05.2023.
//

import UIKit

final class PaymentSelectionFlowTestViewController: TestViewController {
  
  let currencyTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.placeholder = "Currency code"
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
    label.text = "onUpdate callback will be here"
    button.setTitle("Run Payment Selection flow", for: .normal)
    stackView.insertArrangedSubview(currencyTextField, at: 1)
    stackView.addArrangedSubview(onCompleteLabel)
    stackView.addArrangedSubview(onErrorLabel)
  }
  
  override func buttonTapped() {
    manager.setToken(accessTokenTextField.text ?? "")
    manager.presentPaymentSelectionViewController(on: self,
                                                  withCurrencyCode: currencyTextField.text ?? "",
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
