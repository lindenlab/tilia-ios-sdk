//
//  SetPrimaryButtonTextColorTestViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 06.04.2022.
//

import UIKit

final class SetPrimaryButtonTextColorTestViewController: SetColorTestViewController {
  
  override func buttonTapped() {
    manager.setPrimaryButtonTextColor(forLightMode: lightModeColor,
                                      andDarkMode: darkModeColor)
    super.buttonTapped()
  }
  
}
