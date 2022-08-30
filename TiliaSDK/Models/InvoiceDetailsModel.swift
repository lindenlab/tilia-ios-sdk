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
                 items: try container.decode([InvoiceDetailsItemModel].self, forKey: .items))
  }
  
}

struct InvoiceDetailsItemModel: Decodable {
  
  let description: String
  let productSku: String
  let amount: Double
  let currency: String
  let sortOrder: Int?
  
  // TODO: - Fix this when server will send this property
  var displayAmount: String {
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 2
    let amountString = formatter.string(from: NSNumber(value: amount)) ?? ""
    return "\(currency) \(amountString)"
  }
  
  private enum CodingKeys: String, CodingKey {
    case description
    case productSku = "product_sku"
    case amount
    case currency
    case sortOrder = "sort_order"
  }
  
}
