//
//  TransactionHistoryFlowTestViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 15.09.2022.
//

import UIKit

final class TransactionHistoryFlowTestViewController: TestViewController {
  
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
    button.setTitle("Run Transaction History flow", for: .normal)
    stackView.addArrangedSubview(onCompleteLabel)
    stackView.addArrangedSubview(onErrorLabel)
  }
  
  override func buttonTapped() {
    manager.setToken(accessTokenTextField.text ?? "")
    manager.presentTransactionHistoryViewController(on: self,
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
