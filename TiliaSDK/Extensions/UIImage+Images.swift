//
//  UIImage+Images.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import UIKit

extension UIImage {
  
  static let logoIcon = UIImage(str: "logoIcon")
  static let successIcon = UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))
  static let failureIcon = UIImage(systemName: "exclamationmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))
  static let walletIcon = UIImage(str: "walletIcon")
  static let americanExpressIcon = UIImage(str: "americanExpressIcon")
  static let chinaUnionpayIcon = UIImage(str: "chinaUnionpayIcon")
  static let dinersClubIcon = UIImage(str: "dinersClubIcon")
  static let discoverIcon = UIImage(str: "discoverIcon")
  static let jcbIcon = UIImage(str: "jcbIcon")
  static let maestroIcon = UIImage(str: "maestroIcon")
  static let masterCardIcon = UIImage(str: "masterCardIcon")
  static let visaIcon = UIImage(str: "visaIcon")
  static let driversLicenseBackIcon = UIImage(str: "driversLicenseBackIcon")
  static let driversLicenseFrontIcon = UIImage(str: "driversLicenseFrontIcon")
  static let identityCardBackIcon = UIImage(str: "identityCardBackIcon")
  static let identityCardFrontIcon = UIImage(str: "identityCardFrontIcon")
  static let passportIcon = UIImage(str: "passportIcon")
  static let residencePermitBackIcon = UIImage(str: "residencePermitBackIcon")
  static let residencePermitFrontIcon = UIImage(str: "residencePermitFrontIcon")
  static let chevronUpIcon = UIImage(systemName: "chevron.up", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
  static let chevronDownIcon = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
  static let arrowLeftIcon = UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
  static let arrowRightIcon = UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
  static let cameraIcon = UIImage(systemName: "camera.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
  static let documentIcon = UIImage(systemName: "photo.on.rectangle", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
  static let uploadIcon = UIImage(systemName: "icloud.and.arrow.up.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
  static let addIcon = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
  static let closeIcon = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
  
  private convenience init?(str: String) {
    self.init(named: str, in: BundleToken.bundle, compatibleWith: nil)
  }
  
}
