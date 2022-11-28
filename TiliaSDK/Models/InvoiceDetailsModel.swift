//
//  InvoiceDetailsModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 31.03.2022.
//

import Foundation

struct InvoiceDetailsModel: Decodable {
  
  let isEscrow: Bool
  let isVirtual: Bool
  let info: InvoiceInfoModel
  
  private enum CodingKeys: String, CodingKey {
    case isEscrow = "is_escrow"
    case isVirtual = "is_virtual"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    isEscrow = try container.decode(Bool.self, forKey: .isEscrow)
    isVirtual = try container.decode(Bool.self, forKey: .isVirtual)
    info = try .init(from: decoder)
  }
  
}
