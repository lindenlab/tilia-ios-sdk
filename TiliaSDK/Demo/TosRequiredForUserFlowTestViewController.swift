//
//  TosRequiredForUserFlowTestViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import UIKit

final class TosRequiredForUserFlowTestViewController: TestViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    button.setTitle("Run TOS flow", for: .normal)
  }
  
  override func buttonTapped() {
    super.buttonTapped()
    manager.getTosRequiredForUser { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let isTosSigned):
        self.label.text = "State is \(isTosSigned)"
        if !isTosSigned {
          self.manager.presentTosIsRequiredViewController(on: self, animated: true) {
            self.label.text = $0.description
          } onError: {
            self.label.text = $0.description
          }
        }
      case .failure(let error):
        self.label.text = error.localizedDescription
      }
    }
  }
  
}
