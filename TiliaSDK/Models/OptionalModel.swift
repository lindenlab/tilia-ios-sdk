//
//  OptionalModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 19.10.2022.
//

import Foundation

struct OptionalModel<T: Decodable>: Decodable {
  
  let model: T?
  
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    model = try? container.decode(T.self)
  }
  
}
