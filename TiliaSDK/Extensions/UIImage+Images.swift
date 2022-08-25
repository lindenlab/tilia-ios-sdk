//
//  UIImage+Images.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import UIKit

extension UIImage {
  
  static let logoIcon = UIImage(str: "logoIcon")
  static let successIcon = UIImage(str: "successIcon")
  static let failureIcon = UIImage(str: "failureIcon")
  static let walletIcon = UIImage(str: "walletIcon")
  static let americanExpressIcon = UIImage(str: "americanExpressIcon")
  static let chinaUnionpayIcon = UIImage(str: "chinaUnionpayIcon")
  static let dinersClubIcon = UIImage(str: "dinersClubIcon")
  static let discoverIcon = UIImage(str: "discoverIcon")
  static let jcbIcon = UIImage(str: "jcbIcon")
  static let maestroIcon = UIImage(str: "maestroIcon")
  static let masterCardIcon = UIImage(str: "masterCardIcon")
  static let visaIcon = UIImage(str: "visaIcon")
  
  static let closeIcon = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
  
  private convenience init?(str: String) {
    self.init(named: str, in: BundleToken.bundle, compatibleWith: nil)
  }
  
}
