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
    
    accessTokenTextField.text = "eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJhY2NvdW50X2lkIjoiZThiMjhmYzMtNWJkOC00YTVhLWJhZmYtOTJiMTg4MTMzM2RhIiwiY2xpZW50X2lkIjoiY2Y5YThhNDktNjM5Ny00M2Q4LTljMzctYzcwN2FlMjNmNTNhIiwiZXhwIjoxNjQ4ODQxMjU0LCJpYXQiOjE2NDg4Mzc2NTQsImludGVncmF0b3IiOiJ0aWxpYS1zZGtzIiwianRpIjoiMGM5MWEyYzgtOWIzYi00NTk3LWI3NDktZjhlMGQyYjAwMzliIiwibmJmIjowLCJzY29wZXMiOlsidXNlcl9pbmZvIiwicmVhZF9wYXltZW50X21ldGhvZCIsIndyaXRlX3BheW1lbnRfbWV0aG9kIiwicmVhZF9reWMiLCJ2ZXJpZnlfa3ljIiwid3JpdGVfaW52b2ljZSIsInJlYWRfaW52b2ljZSJdLCJ0b2tlbl90eXBlIjoicGFzc3dvcmQiLCJ1c2VybmFtZSI6ImphbmVzbWl0aEBmYWtlZW1haWwuY29tIn0.K-Z8TTrtmSOHkayEgyBPn8XjxxMl9tG7zjrqTECVvcHYoyyxc5xmDOR0mhrgJMsXc-Y_DVFGalyPG0FeGbItawd8Q0L0lIBQf_0Z50RC40X9aoLu7HxwYVc2RQaUFO6-GeceKhyXF6DVmc7xZpkAM4SQcO5mEualVythLVIo3LFAXEm0bjNYG1Llf69k0SRNu21yNhshCUeN9jE1ygkK0Qbcp2cH-qOZzUlKrlDZ5dNoH2Z5LuZylv-8X0bZz5dgigfe8g7-kMh77xTwsze_RWV8ylnR-Ps75caBw9JvesguTWj7AwwflAar9Nq3UargGeV7uFhGS4LaLYlhGjlrLw"
    invoiceIdTextField.text = "d69079d3-380c-4113-8fa0-36717b78fcc3"
  }
  
  override func buttonTapped() {
    super.buttonTapped()
    manager.presentCheckoutViewController(on: self,
                                          withInvoiceId: invoiceIdTextField.text ?? "",
                                          animated: true) { [weak self] in
      self?.label.text = "Checkout state: \($0)"
    }
  }
  
}
