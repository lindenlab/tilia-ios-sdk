//
//  UIImage+Images.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import UIKit
import PocketSVG

extension UIImage {
  
  static let logoIcon = UIImage(str: "logoIcon")
  static let walletIcon = UIImage(str: "walletIcon")
  static let americanExpressIcon = UIImage(str: "americanExpressIcon")
  static let chinaUnionpayIcon = UIImage(str: "chinaUnionpayIcon")
  static let dinersClubIcon = UIImage(str: "dinersClubIcon")
  static let discoverIcon = UIImage(str: "discoverIcon")
  static let jcbIcon = UIImage(str: "jcbIcon")
  static let maestroIcon = UIImage(str: "maestroIcon")
  static let masterCardIcon = UIImage(str: "masterCardIcon")
  static let visaIcon = UIImage(str: "visaIcon")
  
  static let successIcon = UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))
  static let failureIcon = UIImage(systemName: "exclamationmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium))
  static let chevronUpIcon = UIImage(systemName: "chevron.up", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
  static let chevronDownIcon = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
  static let arrowLeftIcon = UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
  static let arrowRightIcon = UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
  static let cameraIcon = UIImage(systemName: "camera.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
  static let documentIcon = UIImage(systemName: "photo.on.rectangle", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
  static let uploadIcon = UIImage(systemName: "icloud.and.arrow.up.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
  static let addIcon = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
  static let closeIcon = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
  
  static var driversLicenseBackIcon: UIImage? { return svgImage(for: "DriversLicenseBackImage") }
  static var driversLicenseFrontIcon: UIImage? { return svgImage(for: "DriversLicenseFrontImage") }
  static var identityCardBackIcon: UIImage? { return svgImage(for: "IdentityCardBackImage") }
  static var identityCardFrontIcon: UIImage? { return svgImage(for: "IdentityCardFrontImage") }
  static var passportIcon: UIImage? { return svgImage(for: "PassportImage") }
  static var residencePermitBackIcon: UIImage? { return svgImage(for: "ResedencePermitBackImage") }
  static var residencePermitFrontIcon: UIImage? { return svgImage(for: "ResedencePermitFrontImage") }
  
}

private extension UIImage {
  
  convenience init?(str: String) {
    self.init(named: str, in: BundleToken.bundle, compatibleWith: nil)
  }
  
  static func svgImage(for name: String) -> UIImage? {
    guard let path = BundleToken.bundle.url(forResource: name, withExtension: "svg") else { return nil }
    let imageView = SVGImageView(contentsOf: path)
    imageView.frame = imageView.viewBox
    imageView.layer.layoutIfNeeded()
    
    guard let layers = imageView.layer.sublayers?.compactMap({ $0 as? CAShapeLayer }) else { return nil }
    layers.forEach { layer in
      if let fillColor = layer.fillColor, var components = fillColor.components {
        components.removeLast()
        if components != [1, 1, 1] {
          layer.fillColor = UIColor.primaryColor.cgColor
        }
      }
      if let strokeColor = layer.strokeColor, var components = strokeColor.components {
        components.removeLast()
        if components != [1, 1, 1] {
          layer.strokeColor = UIColor.primaryColor.cgColor
        }
      }
    }
    
    var size = imageView.viewBox.size
    size.height += 2
    size.width += 2
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { imageView.layer.render(in: $0.cgContext) }
  }
  
}
