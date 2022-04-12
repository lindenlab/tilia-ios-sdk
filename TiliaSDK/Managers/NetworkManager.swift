//
//  NetworkManager.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 11.04.2022.
//

import Foundation

final class NetworkManager {
  
  let serverConfiguration: ServerConfiguration
  private let serverClient: ServerClientProtocol
  
  init(serverClient: ServerClientProtocol,
       token: String? = nil,
       timeoutInterval: Double = 30,
       environment: TLEnvironment = .staging) {
    self.serverClient = serverClient
    serverConfiguration = ServerConfiguration(token: token,
                                              timeoutInterval: timeoutInterval,
                                              environment: environment)
  }
  
  func getTosRequiredForUser(completion: @escaping CompletionResultHandler<TosModel>) {
    let router = AccountRouter.getTosRequiredForUser
    serverClient.performRequestWithDecodableModel(router: router, completion: completion)
  }
  
  func signTosForUser(completion: @escaping CompletionResultHandler<EmptyModel>) {
    let router = AccountRouter.signTosForUser
    serverClient.performRequestWithDecodableModel(router: router, completion: completion)
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
    serverClient.performRequestWithDecodableModel(router: router, completion: completionHandler)
  }
  
  func getInvoiceDetails(with id: String, completion: @escaping CompletionResultHandler<InvoiceDetailsModel>) {
    let router = InvoiceRouter.getInvoiceDetails(id: id)
    serverClient.performRequestWithDecodableModel(router: router, completion: completion)
  }
  
  func createInvoice(withId id: String, isEscrow: Bool, completion: @escaping CompletionResultHandler<InvoiceModel>) {
    let router = InvoiceRouter.createInvoice(id: id, isEscrow: isEscrow)
    serverClient.performRequestWithDecodableModel(router: router, completion: completion)
  }
  
  func payInvoice(withId id: String, isEscrow: Bool, completion: @escaping CompletionResultHandler<EmptyModel>) {
    let router = InvoiceRouter.payInvoice(id: id, isEscrow: isEscrow)
    serverClient.performRequestWithDecodableModel(router: router, completion: completion)
  }
  
}
