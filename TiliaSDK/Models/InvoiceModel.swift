//
//  InvoiceModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 31.03.2022.
//

import Foundation

struct InvoiceModel: Decodable {
  
  let referenceType: String
  let referenceId: String
  let displayAmount: String
  let invoiceId: String
  let items: [String: InvoiceItemModel]
  
  var itemsArray: [InvoiceItemModel] { return Array(items.values) }
  
  private enum CodingKeys: String, CodingKey {
    case referenceType = "reference_type"
    case referenceId = "reference_id"
    case displayAmount = "display_amount"
    case invoiceId = "invoice_id"
    case items = "line_items"
    case summary
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let nestedContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .summary)
    self.referenceType = try container.decode(String.self, forKey: .referenceType)
    self.referenceId = try container.decode(String.self, forKey: .referenceId)
    self.displayAmount = try nestedContainer.decode(String.self, forKey: .displayAmount)
    self.invoiceId = try container.decode(String.self, forKey: .invoiceId)
    self.items = try container.decode([String: InvoiceItemModel].self, forKey: .items)
  }
  
}

struct InvoiceItemModel: Decodable {
  
  let description: String
  let productSku: String
  let displayAmount: String
  
  private enum CodingKeys: String, CodingKey {
    case description
    case productSku = "product_sku"
    case displayAmount = "display_amount"
  }
  
}
