//
//  String+Helpers.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 31.03.2022.
//

import Foundation

extension String {
  
  var localized: String {
    return NSLocalizedString(self, tableName: "LocalizedConstants", bundle: BundleToken.bundle, value: self, comment: "")
  }
  
  func newString(forRange range: NSRange, withReplacementString replacementString: String) -> String? {
    guard let range = Range(range, in: self) else { return nil }
    return self.replacingCharacters(in: range, with: replacementString)
  }
  
}
