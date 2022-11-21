//
//  UserBalanceByCurrencyTestViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import UIKit

final class UserBalanceByCurrencyTestViewController: TestViewController {
  
  let currencyTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.placeholder = "Currency code"
    return textField
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    currencyTextField.delegate = self
    button.setTitle("Run getUserBalanceByCurrency", for: .normal)
    stackView.insertArrangedSubview(currencyTextField, at: 1)
  }
  
  override func buttonTapped() {
    super.buttonTapped()
    manager.getUserBalanceByCurrencyCode(currencyTextField.text ?? "") { [weak self] result in
      switch result {
      case .success(let balance):
        self?.label.text = "User balance is: \(balance)"
      case .failure(let error):
        self?.label.text = error.localizedDescription
      }
    }
  }
  
}
