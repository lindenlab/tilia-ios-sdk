//
//  InvoiceDetailsModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 31.03.2022.
//

import Foundation

struct InvoiceDetailsModel: Decodable {
  
  let isEscrow: Bool
  let currency: String
  
  private enum CodingKeys: String, CodingKey {
    case isEscrow = "is_escrow"
    case currency = "line_items_currency"
  }
  
}
