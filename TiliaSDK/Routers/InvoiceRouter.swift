//
//  InvoiceRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Alamofire

enum InvoiceRouter: RouterProtocol {
  
  case getAuthorizedInvoiceDetails(id: String)
  case createNonEscrowInvoice(id: String)
  case payNonEscrowInvoice(id: String)
  case createEscrowInvoice(id: String)
  case payEscrowInvoice(id: String)
  
  var method: HTTPMethod {
    switch self {
    case .getAuthorizedInvoiceDetails: return .get
    default: return .post
    }
  }
  
  var bodyParameters: Parameters? {
    switch self {
    case .createNonEscrowInvoice(let id), .createEscrowInvoice(let id): return ["authorized_invoice_id": id]
    default: return nil
    }
  }
  
  var service: String { return "invoicing" }
  
  var endpoint: String {
    switch self {
    case .getAuthorizedInvoiceDetails(let id): return "/v2/authorize/invoice/\(id)"
    case .createNonEscrowInvoice: return "/v2/invoice"
    case .payNonEscrowInvoice(let id): return "/v2/invoice/\(id)/pay"
    case .createEscrowInvoice: return "/v2/escrow"
    case .payEscrowInvoice(let id): return "/v2/escrow/\(id)/pay"
    }
  }
  
}
