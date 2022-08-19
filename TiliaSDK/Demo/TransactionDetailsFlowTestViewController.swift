//
//  TransactionDetailsFlowTestViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 19.08.2022.
//

import UIKit

final class TransactionDetailsFlowTestViewController: TestViewController {
  
  let invoiceIdTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.placeholder = "Invoice id"
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
    label.text = "onUpdate callback will be here"
    button.setTitle("Run Transaction Details flow", for: .normal)
    stackView.insertArrangedSubview(invoiceIdTextField, at: 1)
    stackView.addArrangedSubview(onCompleteLabel)
    stackView.addArrangedSubview(onErrorLabel)
  }
  
  override func buttonTapped() {
    manager.setToken(accessTokenTextField.text ?? "")
    manager.presentTransactionDetailsViewController(on: self,
                                                    withInvoiceId: invoiceIdTextField.text ?? "",
                                                    animated: true) { [weak self] in
      self?.label.attributedText = Self.attributedString(text: "onUpdate callback",
                                                         message: $0.description)
    } onComplete: { [weak self] in
      self?.onCompleteLabel.attributedText = Self.attributedString(text: "onComplete callback",
                                                                   message: $0.description)
    } onError: { [weak self] in
      self?.onErrorLabel.attributedText = Self.attributedString(text: "onError callback",
                                                                message: $0.description)
    }
  }
  
}
