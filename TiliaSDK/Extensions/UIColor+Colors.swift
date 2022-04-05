//
//  UIColor+Colors.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 29.03.2022.
//

import UIKit

extension UIColor {
  
  private static var configuration: ColorsConfiguration { return TLManager.shared.colorsConfiguration }
  
  static var backgroundColor: UIColor {
    return UIColor {
      if $0.userInterfaceStyle == .dark {
        return configuration.backgroundColor?.darkModeColor ?? .customBlack
      } else {
        return configuration.backgroundColor?.lightModeColor ?? .white
      }
    }
  }
  
  static var primaryColor: UIColor {
    return UIColor {
      if $0.userInterfaceStyle == .dark {
        return configuration.primaryColor?.darkModeColor ?? .royalBlue
      } else {
        return configuration.primaryColor?.lightModeColor ?? .royalBlue
      }
    }
  }
  
  static var primaryButtonTextColor: UIColor {
    return UIColor {
      if let primaryButtonTextColor = configuration.primaryButtonTextColor {
        if $0.userInterfaceStyle == .dark {
          return primaryButtonTextColor.darkModeColor
        } else {
          return primaryButtonTextColor.lightModeColor
        }
      } else {
        return primaryColor.isColorDark() ? .white : .customBlack
      }
    }
  }
  
  static var primaryTextColor: UIColor {
    return UIColor {
      if let primaryTextColor = configuration.primaryTextColor {
        if $0.userInterfaceStyle == .dark {
          return primaryTextColor.darkModeColor
        } else {
          return primaryTextColor.lightModeColor
        }
      } else {
        return backgroundColor.isColorDark() ? .white : .customBlack
      }
    }
    
  }
  
  static var secondaryTextColor: UIColor {
    return UIColor { _ in
      return primaryTextColor.withAlphaComponent(0.75)
    }
  }
  
  static var tertiaryTextColor: UIColor {
    return UIColor { _ in
      return primaryTextColor.withAlphaComponent(0.45)
    }
  }
  
  static var borderColor: UIColor {
    return UIColor { _ in
      return backgroundColor.isColorDark() ? .customWhite : .customBlack.withAlphaComponent(0.18)
    }
  }
  
  
  private static let royalBlue = UIColor(red: 0, green: 0.302, blue: 0.6, alpha: 1)
  private static let customBlack = UIColor(red: 0.108, green: 0.133, blue: 0.158, alpha: 1)
  private static let customWhite = UIColor(white: 1, alpha: 0.18)
  
}

extension UIColor {
  
  func image(with size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
    return UIGraphicsImageRenderer(size: size).image { context in
      self.setFill()
      context.fill(CGRect(origin: .zero, size: size))
    }
  }
  
}

// MARK: - Private Methods

private extension UIColor {
  
  func isColorDark() -> Bool {
    var r: CGFloat = 0.0
    var g: CGFloat = 0.0
    var b: CGFloat = 0.0
    getRed(&r, green: &g, blue: &b, alpha: nil)
    let yiq = (r * 255 * 299 + g * 255 * 587 + b * 255 * 114) / 1000
    return yiq < 128
  }
  
}
