//
//  PaymentRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Alamofire

enum PaymentRouter: RouterProtocol {
  
  var method: HTTPMethod { return .get }
  
  var bodyParameters: Parameters? { return nil }
  
  var service: String { return "payments" }
  
  var endpoint: String { return "" }
  
}
