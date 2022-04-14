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
    textField.placeholder = "Invoice id"
    textField.accessibilityIdentifier = "invoiceIdTextField"
    return textField
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    stackView.addArrangedSubview(invoiceIdTextField)
  }
  
  override func buttonTapped() {
    super.buttonTapped()
    manager.presentCheckoutViewController(on: self,
                                          withInvoiceId: invoiceIdTextField.text ?? "",
                                          animated: true) { [weak self] in
      self?.label.text = "Checkout state: \($0.message)"
    } onComplete: { [weak self] in
      self?.label.text = "Checkout state: \($0.state.rawValue)"
    } onError: { [weak self] in
      self?.label.text = "Checkout state: \($0.message)"
    }
  }
  
}
