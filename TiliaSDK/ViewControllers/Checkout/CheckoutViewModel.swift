//
//  CheckoutViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import Combine

protocol CheckoutViewModelInputProtocol {
}

protocol CheckoutViewModelOutputProtocol {
}

protocol CheckoutViewModelProtocol: CheckoutViewModelInputProtocol, CheckoutViewModelOutputProtocol { }

final class CheckoutViewModel: CheckoutViewModelProtocol {
  
  private let invoiceId: String
  private let manager = TLManager.shared
  
  init(invoiceId: String) {
    self.invoiceId = invoiceId
  }
  
}
