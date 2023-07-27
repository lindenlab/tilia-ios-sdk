//
//  AddPaymentMethodMode.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 11.06.2023.
//

import Foundation

enum AddPaymentMethodMode {
  
  case creditCard
  case paypal
  
  var router: AuthRouter {
    switch self {
    case .creditCard: return .getCreditCardRedirectUrl
    case .paypal: return .getPaypalRedirectUrl
    }
  }
  
  var title: String {
    switch self {
    case .creditCard: return L.addCreditCardTitle
    case .paypal: return L.addPaypalTitle
    }
  }
  
  var message: String {
    switch self {
    case .creditCard: return L.addCreditCardMessage
    case .paypal: return L.addPaypalMessage
    }
  }
  
}
