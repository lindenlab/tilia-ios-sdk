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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    button.setTitle("Run Checkout flow", for: .normal)
    stackView.insertArrangedSubview(invoiceIdTextField, at: 1)
  }
  
  override func buttonTapped() {
    super.buttonTapped()
    manager.presentCheckoutViewController(on: self,
                                          withInvoiceId: invoiceIdTextField.text ?? "",
                                          animated: true) { [weak self] in
      self?.label.text = $0.description
    } onComplete: { [weak self] in
      self?.label.text = $0.description
    } onError: { [weak self] in
      self?.label.text = $0.description
    }
  }
  
}
