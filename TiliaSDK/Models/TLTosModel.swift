//
//  TLTosModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 21.03.2022.
//

import Foundation

public struct TLTosModel: Decodable {
  
  let isSignedTos: Bool
  
  private enum CodingKeys: String, CodingKey {
    case isSignedTos = "signed_tos"
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    isSignedTos = try container.decode(Bool.self, forKey: .isSignedTos)
  }
  
}
