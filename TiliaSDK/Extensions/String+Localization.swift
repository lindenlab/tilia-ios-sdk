//
//  String+Localization.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 31.03.2022.
//

import Foundation

extension String {
  
  var localized: String {
    return NSLocalizedString(self, tableName: "LocalizedConstants", bundle: BundleToken.bundle, value: self, comment: "")
  }
  
}
