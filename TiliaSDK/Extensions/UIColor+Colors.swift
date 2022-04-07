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
    return UIColor { _ in
      return primaryColor.isColorDark() ? .white : .customBlack
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
  
  static var successBackgroundColor: UIColor {
    return UIColor {
      if let successBackgroundColor = configuration.successBackgroundColor {
        if $0.userInterfaceStyle == .dark {
          return successBackgroundColor.darkModeColor
        } else {
          return successBackgroundColor.lightModeColor
        }
      } else {
        return .customGreen
      }
    }
  }
  
  static var successPrimaryColor: UIColor {
    return UIColor { _ in
      return successBackgroundColor.isColorDark() ? .white : .customBlack
    }
  }
  
  private static let royalBlue = UIColor(red: 0, green: 0.302, blue: 0.6, alpha: 1)
  private static let customBlack = UIColor(red: 0.108, green: 0.133, blue: 0.158, alpha: 1)
  private static let customWhite = UIColor(white: 1, alpha: 0.18)
  private static let customGreen = UIColor(red: 0.22, green: 0.631, blue: 0.412, alpha: 1)
  
}

extension UIColor {
  
  convenience init(hexString: String, alpha: CGFloat = 1.0) {
    var hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    let scanner = Scanner(string: hexString)
    if (hexString.hasPrefix("#")) {
      hexString.remove(at: hexString.startIndex)
    }
    var color: UInt64 = 0
    scanner.scanHexInt64(&color)
    let mask = 0x000000FF
    let r = Int(color >> 16) & mask
    let g = Int(color >> 8) & mask
    let b = Int(color) & mask
    let red   = CGFloat(r) / 255.0
    let green = CGFloat(g) / 255.0
    let blue  = CGFloat(b) / 255.0
    self.init(red:red, green:green, blue:blue, alpha:alpha)
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
