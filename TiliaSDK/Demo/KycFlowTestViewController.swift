//
//  KycFlowTestViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 02.05.2022.
//

import UIKit

final class KycFlowTestViewController: TestViewController {
  
  override func buttonTapped() {
    manager.setToken(accessTokenTextField.text ?? "")
    manager.presentKycViewController(on: self, animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    button.setTitle("Run KYC flow", for: .normal)
  }
  
}
