//
//  SetSuccessBackgroundColorTestViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 07.04.2022.
//

import UIKit

final class SetSuccessBackgroundColorTestViewController: SetColorTestViewController {
  
  override func buttonTapped() {
    manager.setSuccessBackgroundColor(forLightMode: lightModeColor,
                                      andDarkMode: darkModeColor)
    super.buttonTapped()
  }
  
}
