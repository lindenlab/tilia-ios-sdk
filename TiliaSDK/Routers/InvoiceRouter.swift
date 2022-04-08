//
//  InvoiceRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Alamofire

enum InvoiceRouter: RouterProtocol {
  
  case getInvoiceDetails(id: String)
  case createInvoice(id: String, isEscrow: Bool)
  case payInvoice(id: String, isEscrow: Bool)
  
  var method: HTTPMethod {
    switch self {
    case .getInvoiceDetails: return .get
    default: return .post
    }
  }
  
  var bodyParameters: Parameters? {
    switch self {
    case let .createInvoice(id, _): return ["authorized_invoice_id": id]
    default: return nil
    }
  }
  
  var service: String { return "invoicing" }
  
  var endpoint: String {
    switch self {
    case let .getInvoiceDetails(id): return "/v2/authorize/invoice/\(id)"
    case let .createInvoice(_, isEscrow): return isEscrow ? "/v2/escrow" : "/v2/invoice"
    case let .payInvoice(id, isEscrow): return isEscrow ? "/v2/escrow/\(id)/pay" : "/v2/invoice/\(id)/pay"
    }
  }
  
}
