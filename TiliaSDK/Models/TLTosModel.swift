//
//  TLTosModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 21.03.2022.
//

import Foundation

public struct TLTosModel: Decodable {
  
  public let isTosSigned: Bool
  
  private enum CodingKeys: String, CodingKey {
    case isTosSigned = "signed_tos"
  }
  
}
