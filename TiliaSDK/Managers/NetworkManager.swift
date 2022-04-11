//
//  NetworkManager.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 11.04.2022.
//

import Foundation

struct NetworkManager<T: ServerClientProtocol> {
  
  var serverConfiguration: ServerConfiguration
  
  init(token: String? = nil,
       timeoutInterval: Double = 30,
       environment: TLEnvironment = .staging) {
    serverConfiguration = ServerConfiguration(token: token,
                                              timeoutInterval: timeoutInterval,
                                              environment: environment)
  }
  
  func getTosRequiredForUser(completion: @escaping CompletionResultHandler<TosModel>) {
    let router = AccountRouter.getTosRequiredForUser
    T.performRequestWithDecodableModel(router: router, completion: completion)
  }
  
  func signTosForUser(completion: @escaping CompletionResultHandler<EmptyModel>) {
    let router = AccountRouter.signTosForUser
    T.performRequestWithDecodableModel(router: router, completion: completion)
  }
  
  func getUserBalanceByCurrencyCode(_ currencyCode: String, completion: @escaping CompletionResultHandler<BalanceModel>) {
    let completionHandler: CompletionResultHandler<BalancesModel> = { result in
      switch result {
      case .success(let model):
        if let balanceModel = model.balances[currencyCode] {
          completion(.success(balanceModel.spendable))
        } else {
          completion(.failure(TLError.userBalanceDoesNotExistForCurrency(currencyCode)))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
    let router = PaymentRouter.getUserBalanceByCurrencyCode
    T.performRequestWithDecodableModel(router: router, completion: completionHandler)
  }
  
  func getInvoiceDetails(with id: String, completion: @escaping CompletionResultHandler<InvoiceDetailsModel>) {
    let router = InvoiceRouter.getInvoiceDetails(id: id)
    T.performRequestWithDecodableModel(router: router, completion: completion)
  }
  
  func createInvoice(withId id: String, isEscrow: Bool, completion: @escaping CompletionResultHandler<InvoiceModel>) {
    let router = InvoiceRouter.createInvoice(id: id, isEscrow: isEscrow)
    T.performRequestWithDecodableModel(router: router, completion: completion)
  }
  
  func payInvoice(withId id: String, isEscrow: Bool, completion: @escaping CompletionResultHandler<EmptyModel>) {
    let router = InvoiceRouter.payInvoice(id: id, isEscrow: isEscrow)
    T.performRequestWithDecodableModel(router: router, completion: completion)
  }
  
}
