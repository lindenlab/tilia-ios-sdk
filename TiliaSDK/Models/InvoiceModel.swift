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
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: RootCodingKeys.self)
    // Check if invoice is non escrow or escrow
    if container.contains(.invoiceId) {
      self.invoiceId = try container.decode(String.self, forKey: .invoiceId)
      self.info = try .init(from: decoder)
    } else {
      self.invoiceId = try container.decode(String.self, forKey: .escrowInvoiceId)
      self.info = try container.decode(InvoiceInfoModel.self, forKey: .escrowInvoice)
    }
  }
  
}
