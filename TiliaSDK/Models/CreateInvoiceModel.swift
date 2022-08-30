//
//  CreateInvoiceModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 19.04.2022.
//

import Foundation

struct CreateInvoiceModel: Encodable {
  
  let invoiceId: String
  let paymentMethods: [CheckoutPaymentMethodModel]?
  
  private enum CodingKeys: String, CodingKey {
    case invoiceId = "authorized_invoice_id"
    case paymentMethods = "payment_methods"
  }
  
}
