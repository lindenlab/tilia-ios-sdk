//
//  DeletePaymentMethodViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 25.05.2023.
//

import Foundation
import Combine

protocol DeletePaymentMethodViewModelInputProtocol {
  
}

protocol DeletePaymentMethodViewModelOutputProtocol {
  
}

protocol DeletePaymentMethodViewModelProtocol: DeletePaymentMethodViewModelInputProtocol, DeletePaymentMethodViewModelOutputProtocol {
  
}

final class DeletePaymentMethodViewModel: DeletePaymentMethodViewModelProtocol {
  
  private let manager: NetworkManager
  private let paymentMethodId: String
  private let onDelete: () -> Void
  private let onUpdate: ((TLUpdateCallback) -> Void)?
  private let onError: ((TLErrorCallback) -> Void)?
  
  init(manager: NetworkManager,
       paymentMethodId: String,
       onDelete: @escaping () -> Void,
       onUpdate: ((TLUpdateCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    self.manager = manager
    self.paymentMethodId = paymentMethodId
    self.onDelete = onDelete
    self.onUpdate = onUpdate
    self.onError = onError
  }
  
}
