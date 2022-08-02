//
//  KycFlowTestViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 02.05.2022.
//

import UIKit

final class KycFlowTestViewController: TestViewController {
  
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
    button.setTitle("Run KYC flow", for: .normal)
    label.text = "onUpdate callback will be here"
    stackView.addArrangedSubview(onCompleteLabel)
    stackView.addArrangedSubview(onErrorLabel)
  }
  
  override func buttonTapped() {
    manager.setToken(accessTokenTextField.text ?? "")
    manager.presentKycViewController(on: self,
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
