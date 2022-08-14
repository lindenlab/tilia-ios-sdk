//
//  TosContentModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 12.08.2022.
//

import Foundation

struct TosContentModel: Decodable {
  
  let content: String
  
  private enum CodingKeys: String, CodingKey {
    case content = "tos_content"
  }
  
}
