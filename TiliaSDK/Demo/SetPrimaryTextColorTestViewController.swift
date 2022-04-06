//
//  SetPrimaryTextColorTestViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 06.04.2022.
//

import UIKit

final class SetPrimaryTextColorTestViewController: SetColorTestViewController {
  
  override func buttonTapped() {
    manager.setPrimaryTextColor(forLightMode: lightModeColor,
                                andDarkMode: darkModeColor)
    super.buttonTapped()
  }
  
  
}

