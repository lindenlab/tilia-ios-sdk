//
//  IsTosSignedModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 21.03.2022.
//

import Foundation

struct IsTosSignedModel: Decodable {
  
  let isTosSigned: Bool
  
  private enum CodingKeys: String, CodingKey {
    case isTosSigned = "signed_tos"
  }
  
}
