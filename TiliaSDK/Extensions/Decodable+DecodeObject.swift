//
//  Decodable+DecodeObject.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 21.03.2022.
//

import Foundation

extension Decodable {
  
  static func decodeObject(from dataDict: Any?) throws -> Self? {
    guard let dataDict = dataDict, !(dataDict is NSNull) else { return nil }
    let jsonData: Data = try JSONSerialization.data(withJSONObject: dataDict, options: [.prettyPrinted])
    let decoder = JSONDecoder()
    return try decoder.decode(Self.self, from: jsonData)
  }
  
}
