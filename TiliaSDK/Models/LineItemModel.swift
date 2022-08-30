//
//  LineItemModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 25.08.2022.
//

import Foundation

struct LineItemModel: Decodable {
  
  let description: String
  let productSku: String
  let displayAmount: String
  let sortOrder: Int?
  
  private enum CodingKeys: String, CodingKey {
    case description
    case productSku = "product_sku"
    case amount
    case currency
    case displayAmount = "display_amount"
    case sortOrder = "sort_order"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    description = try container.decode(String.self, forKey: .description)
    productSku = try container.decode(String.self, forKey: .productSku)
    sortOrder = try container.decodeIfPresent(Int.self, forKey: .sortOrder)
    // TODO: - Fix this when server will always send this property
    if let displayAmount = try? container.decode(String.self, forKey: .displayAmount) {
      self.displayAmount = displayAmount
    } else {
      let amount = try container.decode(Double.self, forKey: .amount)
      let currency = try container.decode(String.self, forKey: .currency)
      let formatter = NumberFormatter()
      formatter.maximumFractionDigits = 2
      let amountString = formatter.string(from: NSNumber(value: amount)) ?? ""
      displayAmount = "\(currency) \(amountString)"
    }
  }
  
}
