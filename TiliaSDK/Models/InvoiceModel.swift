//
//  InvoiceModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 31.03.2022.
//

import Foundation

struct InvoiceModel: Decodable {
  
  let invoiceId: String
  
  private enum CodingKeys: String, CodingKey {
    case invoiceId = "invoice_id"
    case escrowInvoiceId = "escrow_invoice_id"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if container.contains(.invoiceId) {
      self.invoiceId = try container.decode(String.self, forKey: .invoiceId)
    } else {
      self.invoiceId = try container.decode(String.self, forKey: .escrowInvoiceId)
    }
  }
  
}
