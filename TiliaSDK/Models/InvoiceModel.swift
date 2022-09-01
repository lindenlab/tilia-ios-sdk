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
  
  private enum RootCodingKeys: String, CodingKey {
    case invoiceId = "invoice_id"
    case escrowInvoiceId = "id"
    case escrowInvoice = "escrow_invoice"
  }
  
  private enum InvoiceCodingKeys: String, CodingKey {
    case referenceType = "reference_type"
    case referenceId = "reference_id"
    case summary
    case items = "line_items"
  }
  
  private enum SummaryCodingKeys: String, CodingKey {
    case currency
    case displayAmount = "display_amount"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: RootCodingKeys.self)
    // Check if invoice is non escrow or escrow
    if container.contains(.invoiceId) {
      self.invoiceId = try container.decode(String.self, forKey: .invoiceId)
      let nonEscrowContainer = try decoder.container(keyedBy: InvoiceCodingKeys.self)
      self.info = try Self.infoModel(for: nonEscrowContainer)
    } else {
      self.invoiceId = try container.decode(String.self, forKey: .escrowInvoiceId)
      let escrowContainer = try container.nestedContainer(keyedBy: InvoiceCodingKeys.self, forKey: .escrowInvoice)
      self.info = try Self.infoModel(for: escrowContainer)
    }
  }
  
  private static func infoModel(for container: KeyedDecodingContainer<InvoiceCodingKeys>) throws -> InvoiceInfoModel {
    let summaryContainer = try container.nestedContainer(keyedBy: SummaryCodingKeys.self, forKey: .summary)
    let items = try container.decode([String: LineItemModel].self, forKey: .items)
    return .init(currency: try summaryContainer.decode(String.self, forKey: .currency),
                 referenceType: try container.decode(String.self, forKey: .referenceType),
                 referenceId: try container.decode(String.self, forKey: .referenceId),
                 displayAmount: try summaryContainer.decode(String.self, forKey: .displayAmount),
                 items: items.values.sorted { $0.sortOrder ?? 0 < $1.sortOrder ?? 0 })
  }
  
}
