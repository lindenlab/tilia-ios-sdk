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
  let items: [InvoiceItemModel]
    
  private enum CodingKeys: String, CodingKey {
    case referenceType = "reference_type"
    case referenceId = "reference_id"
    case displayAmount = "display_amount"
    case invoiceId = "invoice_id"
    case items = "line_items"
    case summary
  }
  
  private enum RootCodingKeys: String, CodingKey {
    case escrowInvoice = "escrow_invoice"
    case id
  }
  
  init(from decoder: Decoder) throws {
    let rootContainer = try decoder.container(keyedBy: RootCodingKeys.self)
    let container: KeyedDecodingContainer<CodingKeys>
    if rootContainer.contains(.escrowInvoice) {
      container = try rootContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .escrowInvoice)
      self.invoiceId = try rootContainer.decode(String.self, forKey: .id)
    } else {
      container = try decoder.container(keyedBy: CodingKeys.self)
      self.invoiceId = try container.decode(String.self, forKey: .invoiceId)
    }
    let summaryContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .summary)
    self.referenceType = try container.decode(String.self, forKey: .referenceType)
    self.referenceId = try container.decode(String.self, forKey: .referenceId)
    self.displayAmount = try summaryContainer.decode(String.self, forKey: .displayAmount)
    let itemsDict = try container.decode([String: InvoiceItemModel].self, forKey: .items)
    self.items = Array(itemsDict.values)
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
