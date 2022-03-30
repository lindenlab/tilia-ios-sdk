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
    return textField
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    stackView.addArrangedSubview(invoiceIdTextField)
  }
  
  override func buttonTapped() {
    super.buttonTapped()
    manager.presentCheckoutViewController(on: self,
                                          withInvoiceId: invoiceIdTextField.text!,
                                          animated: true,
                                          completion: nil)
  }
  
}
