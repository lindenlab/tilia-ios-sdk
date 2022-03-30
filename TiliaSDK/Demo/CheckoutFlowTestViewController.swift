//
//  CheckoutFlowTestViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import UIKit

final class CheckoutFlowTestViewController: TestViewController {
  
  override func buttonTapped() {
    super.buttonTapped()
    let vc = CheckoutViewController()
    present(vc, animated: true)
  }
  
}
