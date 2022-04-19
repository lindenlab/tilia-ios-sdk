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
  let currency: String
  let referenceType: String
  let referenceId: String
  let displayAmount: String
  let items: [InvoiceDetailsItemModel]
  
  private enum CodingKeys: String, CodingKey {
    case isEscrow = "is_escrow"
    case isVirtual = "is_virtual"
    case currency = "line_items_currency"
    case referenceType = "reference_type"
    case referenceId = "reference_id"
    case displayAmount = "display_amount"
    case items = "line_items"
  }
  
}

struct InvoiceDetailsItemModel: Decodable {
  
  let description: String
  let productSku: String
  let amount: Double
  let currency: String
  
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
  }
  
}
