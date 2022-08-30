//
//  InvoiceModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 31.03.2022.
//

import Foundation

struct InvoiceModel: Decodable {
  
  let invoiceId: String
  let info: InvoiceInfoModel
  
  private enum CodingKeys: String, CodingKey {
    case invoiceId = "invoice_id"
    case escrowInvoiceId = "id"
    case escrowInvoice = "escrow_invoice"
    case referenceType = "reference_type"
    case referenceId = "reference_id"
    case summary
    case displayAmount = "display_amount"
    case items = "line_items"
    case currency
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    // Check if invoice is non escrow or escrow
    if container.contains(.invoiceId) {
      self.invoiceId = try container.decode(String.self, forKey: .invoiceId)
      self.info = try Self.infoModel(for: container)
    } else {
      let escrowContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .escrowInvoice)
      self.invoiceId = try container.decode(String.self, forKey: .escrowInvoiceId)
      self.info = try Self.infoModel(for: escrowContainer)
    }
  }
  
  private static func infoModel(for container: KeyedDecodingContainer<CodingKeys>) throws -> InvoiceInfoModel {
    let summaryContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .summary)
    let items = (try container.decode([String: LineItemModel].self, forKey: .items)).values.sorted {
      return $0.sortOrder ?? 0 < $1.sortOrder ?? 0
    }
    return .init(currency: try summaryContainer.decode(String.self, forKey: .currency),
                 referenceType: try container.decode(String.self, forKey: .referenceType),
                 referenceId: try container.decode(String.self, forKey: .referenceId),
                 displayAmount: try summaryContainer.decode(String.self, forKey: .displayAmount),
                 items: items)
  }
  
}
