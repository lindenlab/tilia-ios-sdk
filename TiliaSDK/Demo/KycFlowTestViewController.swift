//
//  KycFlowTestViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 02.05.2022.
//

import UIKit

final class KycFlowTestViewController: TestViewController {
  
  override func buttonTapped() {
    super.buttonTapped()
    manager.presentKycViewController(on: self, animated: true)
  }
  
}
