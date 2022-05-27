//
//  UIImage+Images.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import UIKit

extension UIImage {
  
  static let logoImage = UIImage(str: "logoIcon")
  static let successIcon = UIImage(str: "successIcon")
  static let walletIcon = UIImage(str: "walletIcon")
  static let failureIcon = UIImage(str: "failureIcon")
  
  private convenience init?(str: String) {
    self.init(named: str, in: BundleToken.bundle, compatibleWith: nil)
  }
  
}
