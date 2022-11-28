//
//  Data+Serialization.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 21.03.2022.
//

import Foundation

extension Data {
  
  var simpleSerialize: Any? {
    return try? JSONSerialization.jsonObject(with: self, options: [])
  }
  
}
