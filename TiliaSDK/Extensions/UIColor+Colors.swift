//
//  UIColor+Colors.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 29.03.2022.
//

import UIKit

extension UIColor {
  
  static var backgroundColor: UIColor { return .white }
  static var buttonColor: UIColor { return Self.royalBlue }
  static var titleColor: UIColor { return Self.customBlack }
  static var subTitleColor1: UIColor { return Self.grayWithDarkTransparency }
  static var subTitleColor2: UIColor { return Self.grayWithMediumTransparency }
  static var dividerColor: UIColor { return Self.blackWithLightTransparency }
  static var successColor: UIColor { return Self.customGreen }
  
  private static let royalBlue = UIColor(red: 0, green: 0.302, blue: 0.6, alpha: 1)
  private static let grayWithDarkTransparency = UIColor(red: 0.106, green: 0.133, blue: 0.157, alpha: 0.75)
  private static let grayWithMediumTransparency = UIColor(red: 0.106, green: 0.133, blue: 0.157, alpha: 0.45)
  private static let customBlack = UIColor(red: 0.108, green: 0.133, blue: 0.158, alpha: 1)
  private static let blackWithLightTransparency = UIColor(white: 0, alpha: 0.08)
  private static let customGreen = UIColor(red: 0.22, green: 0.631, blue: 0.412, alpha: 1)
  private static let whiteWithDarkTransparency = UIColor(white: 1, alpha: 0.75)
  private static let whiteWithMediumTransparency = UIColor(white: 1, alpha: 0.45)
  private static let whiteWithLightTransparency = UIColor(white: 1, alpha: 0.16)
  private static let customOrange = UIColor(red: 0.929, green: 0.537, blue: 0.212, alpha: 1)
  private static let customBlue = UIColor(white: 0.898, alpha: 1)
  
}

extension UIColor {
  
  func image(with size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
    return UIGraphicsImageRenderer(size: size).image { context in
      self.setFill()
      context.fill(CGRect(origin: .zero, size: size))
    }
  }
  
}
