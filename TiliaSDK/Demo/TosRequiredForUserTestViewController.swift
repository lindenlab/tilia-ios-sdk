//
//  TosRequiredForUserTestViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import UIKit

final class TosRequiredForUserTestViewController: TestViewController {
  
  override func buttonTapped() {
    super.buttonTapped()
    manager.getTosRequiredForUser { [weak self] result in
      switch result {
      case .success(let isTosSigned):
        self?.label.text = "TOS is signed with value: \(isTosSigned)"
      case .failure(let error):
        self?.label.text = error.localizedDescription
      }
    }
  }
  
}
