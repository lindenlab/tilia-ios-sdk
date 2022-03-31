//
//  String+Localization.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 31.03.2022.
//

import Foundation

extension String {
  
  var localized: String {
    return NSLocalizedString(self, tableName: "LocalizedConstants", bundle: .main, value: self, comment: "")
  }
  
  func localized(with arguments: CVarArg...) -> String {
    return String(format: localized, arguments: arguments)
  }
  
}
