//
//  InvoiceInfoModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 29.08.2022.
//

import Foundation

struct InvoiceInfoModel: Decodable {
  
  let currency: String
  let referenceType: String
  let referenceId: String
  let displayAmount: String
  let items: [LineItemModel]
  
  private enum RootCodingKeys: String, CodingKey {
    case referenceType = "reference_type"
    case referenceId = "reference_id"
    case displayAmount = "display_amount"
    case currency = "line_items_currency"
    case items = "line_items"
    case summary
  }
  
  private enum SummaryCodingKeys: String, CodingKey {
    case currency
    case displayAmount = "display_amount"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: RootCodingKeys.self)
    
    referenceType = try container.decode(String.self, forKey: .referenceType)
    referenceId = try container.decode(String.self, forKey: .referenceId)
    
    if let items = try? container.decode([LineItemModel].self, forKey: .items) {
      self.items = items
    } else {
      let items = try container.decode([String: LineItemModel].self, forKey: .items)
      self.items = items.values.sorted { $0.sortOrder ?? 0 < $1.sortOrder ?? 0 }
    }
    
    if container.contains(.summary) {
      let summaryContainer = try container.nestedContainer(keyedBy: SummaryCodingKeys.self, forKey: .summary)
      currency = try summaryContainer.decode(String.self, forKey: .currency)
      displayAmount = try summaryContainer.decode(String.self, forKey: .displayAmount)
    } else {
      currency = try container.decode(String.self, forKey: .currency)
      displayAmount = try container.decode(String.self, forKey: .displayAmount)
    }
  }
  
}
