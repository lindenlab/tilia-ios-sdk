//
//  Decodable+DecodeObject.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 21.03.2022.
//

import Foundation

extension Decodable {
  
  static func decodeObject(from data: Data?) throws -> Self {
    guard let data = data else { throw TLError.decodableDataIsNil }
    let decoder = JSONDecoder()
    return try decoder.decode(Self.self, from: data)
  }
  
}
