//
//  SetBackgroundColorTestViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 06.04.2022.
//

import UIKit

final class SetBackgroundColorTestViewController: SetColorTestViewController {
  
  override func buttonTapped() {
    manager.setBackgroundColor(forLightMode: lightModeColor,
                               andDarkMode: darkModeColor)
    super.buttonTapped()
  }
  
}
