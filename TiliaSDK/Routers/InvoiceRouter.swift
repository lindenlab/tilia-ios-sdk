//
//  InvoiceRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Alamofire

enum InvoiceRouter: RouterProtocol {
  
  case getInvoiceDetails(id: String)
  case createInvoice(isEscrow: Bool, model: CreateInvoiceModel)
  case payInvoice(id: String, isEscrow: Bool)
  
  var method: HTTPMethod {
    switch self {
    case .getInvoiceDetails: return .get
    default: return .post
    }
  }
  
  var bodyParameters: Parameters? {
    switch self {
    case let .createInvoice(_, model): return model.encodedParameters
    default: return nil
    }
  }
  
  var service: String { return "invoicing" }
  
  var endpoint: String {
    switch self {
    case let .getInvoiceDetails(id): return "/v2/authorize/invoice/\(id)"
    case let .createInvoice(isEscrow, _): return isEscrow ? "/v2/escrow" : "/v2/invoice"
    case let .payInvoice(id, isEscrow): return isEscrow ? "/v2/escrow/\(id)/pay" : "/v2/invoice/\(id)/pay"
    }
  }
  
}

// MARK: - For Unit Tests

extension InvoiceRouter {
  
  var testData: Data? {
    switch self {
    case .getInvoiceDetails:
      return readJSONFromFile("GetInvoiceDetailsResponse")
    case let .createInvoice(isEscrow, _):
      return isEscrow ? readJSONFromFile("CreateEscrowInvoiceResponse") : readJSONFromFile("CreateInvoiceResponse")
    case .payInvoice:
      return readJSONFromFile("PayInvoiceResponse")
    }
  }
  
}
