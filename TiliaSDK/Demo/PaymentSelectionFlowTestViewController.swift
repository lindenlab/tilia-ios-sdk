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
    return textField
  }()
  
  let currencyTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.placeholder = "Currency code (optional)"
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
    stackView.insertArrangedSubview(amountTextField, at: 1)
    stackView.insertArrangedSubview(currencyTextField, at: 2)
    stackView.addArrangedSubview(onCompleteLabel)
    stackView.addArrangedSubview(onErrorLabel)
    
    accessTokenTextField.text = "eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJhY2NvdW50X2lkIjoiZThiMjhmYzMtNWJkOC00YTVhLWJhZmYtOTJiMTg4MTMzM2RhIiwiY2xpZW50X2lkIjoiOTE0ZGQ3NTAtZGIxNi00YTIzLThiYjUtZmFkMzBiOGUzYWFhIiwiZXhwIjoxNjg0OTcwMzIzLCJpYXQiOjE2ODQ5NjY3MjMsImludGVncmF0b3IiOiJ0aWxpYS1zZGtzIiwianRpIjoiOGU4YzE1ODAtODViZS00MDU0LTgyMDYtOTY5OWM5YmNiYjdlIiwibmJmIjowLCJzY29wZXMiOlsidXNlcl9pbmZvIiwicmVhZF9wYXltZW50X21ldGhvZCIsIndyaXRlX3BheW1lbnRfbWV0aG9kIiwicmVhZF9reWMiLCJ2ZXJpZnlfa3ljIiwid3JpdGVfa3ljIiwid3JpdGVfdXNlcl90b2tlbiIsIndyaXRlX3Rva2VuIiwicmVhZF9pbnZvaWNlIiwid3JpdGVfaW52b2ljZSIsIndyaXRlX2RlcG9zaXQiLCJyZWFkX2RlcG9zaXQiLCJhZGRfZW1haWwiXSwidG9rZW5fdHlwZSI6InBhc3N3b3JkIiwidXNlcm5hbWUiOiJqYW5lc21pdGhAZmFrZWVtYWlsLmNvbSJ9.uY_9j_zbmDpXWVHmfY_rbT8us-3GeyggfRBUjUGaHR45hcSrgbGdJ0Hodbj5XdgoqrdZtmvRrZaixvkxZKucBBKt7GHg2yKrlin2ciUUj9s-l9rh5Zg0VnpSKhaM5BeQCOD37y-O-TcGfMhXbZ92Vj_WfERapGx_meTthdNcUP01b6afgX2znLNxAW3HwMD2vJqqjJ84M5zmb4GMIGi0OMd2YmSwgLAAwqRpDSvTsH_i6K51-vZ5eZvY62WCXZsK0waiGJMYp3cuebXHGIqTDEJzvEfXfT8gltmLcHvuvAngaPADJcJQ57lDjMlVTa6-Kd8Ob_7hOdfpMnACzxk2Cg"
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
      self.onCompleteLabel.attributedText = Self.attributedString(text: "onComplete callback",
                                                                  message: $0.description)
    } onError: {
      self.onErrorLabel.attributedText = Self.attributedString(text: "onError callback",
                                                               message: $0.description)
    }
  }
  
}
