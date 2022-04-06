//
//  SetPrimaryColorTestViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 06.04.2022.
//

import UIKit

final class SetPrimaryColorTestViewController: SetColorTestViewController {
  
  override func buttonTapped() {
    manager.setPrimaryColor(forLightMode: lightModeColor,
                            andDarkMode: darkModeColor)
    super.buttonTapped()
  }
  
}
