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
    case currency = "line_items_currency"
    case referenceType = "reference_type"
    case referenceId = "reference_id"
    case displayAmount = "display_amount"
    case items = "line_items"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    isEscrow = try container.decode(Bool.self, forKey: .isEscrow)
    isVirtual = try container.decode(Bool.self, forKey: .isVirtual)
    info = .init(currency: try container.decode(String.self, forKey: .currency),
                 referenceType: try container.decode(String.self, forKey: .referenceType),
                 referenceId: try container.decode(String.self, forKey: .referenceId),
                 displayAmount: try container.decode(String.self, forKey: .displayAmount),
                 items: try container.decode([LineItemModel].self, forKey: .items))
  }
  
}
