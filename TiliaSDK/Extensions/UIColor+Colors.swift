//
//  UIColor+Colors.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 29.03.2022.
//

import UIKit

extension UIColor {
  
  static let royalBlue = UIColor(red: 0, green: 0.302, blue: 0.6, alpha: 1)
  static let grayWithDarkTransparency = UIColor(red: 0.106, green: 0.133, blue: 0.157, alpha: 0.75)
  static let grayWithMediumTransparency = UIColor(red: 0.106, green: 0.133, blue: 0.157, alpha: 0.45)
  static let customBlack = UIColor(red: 0.108, green: 0.133, blue: 0.158, alpha: 1)
  static let blackWithLightTransparency = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08)
  static let customRed = UIColor(red: 0.898, green: 0.243, blue: 0.243, alpha: 1)
  static let customGreen = UIColor(red: 0.22, green: 0.631, blue: 0.412, alpha: 1)
  static let customBlue = UIColor(red: 0.192, green: 0.51, blue: 0.808, alpha: 1)
  
}

extension UIColor {
  
  func image(with size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
    return UIGraphicsImageRenderer(size: size).image { context in
      self.setFill()
      context.fill(CGRect(origin: .zero, size: size))
    }
  }
  
}
