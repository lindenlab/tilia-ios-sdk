//
//  TosRequiredForUserFlowTestViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import UIKit

final class TosRequiredForUserFlowTestViewController: TestViewController {
  
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
    label.text = "getTosRequiredForUser result will be here"
    button.setTitle("Run TOS flow", for: .normal)
    stackView.addArrangedSubview(onCompleteLabel)
    stackView.addArrangedSubview(onErrorLabel)
  }
  
  override func buttonTapped() {
    super.buttonTapped()
    manager.getTosRequiredForUser { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let isTosSigned):
        self.label.attributedText = Self.attributedString(text: "getTosRequiredForUser result",
                                                          message: "\(isTosSigned)")
        if !isTosSigned {
          self.manager.presentTosIsRequiredViewController(on: self, animated: true) {
            self.onCompleteLabel.attributedText = Self.attributedString(text: "onComplete callback",
                                                                        message: $0.description)
          } onError: {
            self.onErrorLabel.attributedText = Self.attributedString(text: "onError callback",
                                                                     message: $0.description)
          }
        }
      case .failure(let error):
        self.label.attributedText = Self.attributedString(text: "getTosRequiredForUser result",
                                                          message: error.localizedDescription)
      }
    }
  }
  
}
