//
//  Encodable+EncodeData.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 21.03.2022.
//

import Foundation

extension Encodable {
  
  var encodedData: Data? {
    return try? JSONEncoder().encode(self)
  }
  
  var encodedStringUTF8: String? {
    return self.encodedData?.stringUTF8
  }
  
  var encodedParameters: [String: Any]? {
    return self.encodedData?.simpleSerialize as? [String: Any]
  }
  
}
