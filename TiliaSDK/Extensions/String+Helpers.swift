//
//  String+Helpers.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 31.03.2022.
//

import UIKit

extension String {
  
  var localized: String {
    return NSLocalizedString(self,
                             tableName: "LocalizedConstants",
                             bundle: BundleToken.bundle,
                             value: self,
                             comment: "")
  }
  
  func localized(with arguments: CVarArg...) -> String {
    return String(format: localized, arguments: arguments)
  }
  
  func newString(forRange range: NSRange, withReplacementString replacementString: String) -> String? {
    guard let range = Range(range, in: self) else { return nil }
    return self.replacingCharacters(in: range, with: replacementString)
  }
  
  func attributedString(font: UIFont, color: UIColor, subStrings: [(String, UIFont, UIColor)]) -> NSAttributedString {
    let rootAttributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: color
    ]
    let attributedString = NSMutableAttributedString(string: self,
                                                     attributes: rootAttributes)
    subStrings.forEach { string, font, color in
      guard let range = self.range(of: string) else { return }
      let subStringAttributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color
      ]
      attributedString.addAttributes(subStringAttributes,
                                     range: NSRange(range, in: self))
    }
    return attributedString
  }
  
  func attributedString(font: UIFont, color: UIColor, subStrings: (String, UIFont, UIColor)...) -> NSAttributedString {
    return attributedString(font: font, color: color, subStrings: subStrings)
  }
  
}
