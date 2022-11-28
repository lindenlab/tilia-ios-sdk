//
//  FailableDecodableModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 19.10.2022.
//

import Foundation

struct FailableDecodableModel<T: Decodable>: Decodable {
  
  let model: T?
  
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    model = try? container.decode(T.self)
  }
  
}

struct FailableDecodableArrayModel<Element: Decodable>: Decodable {
  
  let items: [Element]
  
  init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    var items: [Element] = []
    if let count = container.count {
      items.reserveCapacity(count)
    }
    while !container.isAtEnd {
      if let item = try container.decode(FailableDecodableModel<Element>.self).model {
        items.append(item)
      }
    }
    self.items = items
  }
  
}
