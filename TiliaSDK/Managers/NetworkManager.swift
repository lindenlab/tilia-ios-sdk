//
//  NetworkManager.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 11.04.2022.
//

import Foundation

final class NetworkManager {
  
  let serverConfiguration: ServerConfiguration
  private var serverClient: ServerClientProtocol
  
  init(serverClient: ServerClientProtocol,
       token: String? = nil,
       timeoutInterval: Double = 30,
       environment: TLEnvironment = .staging) {
    self.serverClient = serverClient
    serverConfiguration = ServerConfiguration(token: token,
                                              timeoutInterval: timeoutInterval,
                                              environment: environment)
  }
  
  func getTosRequiredForUser(completion: @escaping CompletionResultHandler<IsTosSignedModel>) {
    let router = AccountRouter.getTosRequiredForUser
    serverClient.performRequestWithBaseResponseDecodableModel(router: router, completion: completion)
  }
  
  func getTosContent(completion: @escaping CompletionResultHandler<TosContentModel>) {
    let router = AccountRouter.getTosContent
    serverClient.performRequestWithBaseResponseDecodableModel(router: router, completion: completion)
  }
  
  func signTosForUser(completion: @escaping CompletionResultHandler<EmptyModel>) {
    let router = AccountRouter.signTosForUser
    serverClient.performRequestWithBaseResponseDecodableModel(router: router, completion: completion)
  }
  
  func getUserInfo(completion: @escaping CompletionResultHandler<UserDetailInfoModel>) {
    let router = AccountRouter.getUserInfo
    serverClient.performRequestWithBaseResponseDecodableModel(router: router, completion: completion)
  }
  
  func beginVerifyUserEmail(_ email: String, completion: @escaping CompletionResultHandler<BeginVerifyUserEmailModel>) {
    let router = AccountRouter.beginVerifyUserEmail(email)
    serverClient.performRequestWithBaseResponseDecodableModel(router: router, completion: completion)
  }
  
  func finishVerifyUserEmail(with model: FinishVerifyUserEmailModel, completion: @escaping CompletionResultHandler<EmptyModel>) {
    let router = AccountRouter.finishVerifyUserEmail(model: model)
    serverClient.performRequestWithBaseResponseDecodableModel(router: router, completion: completion)
  }
  
  func getUserBalanceByCurrencyCode(_ currencyCode: String, completion: @escaping CompletionResultHandler<BalanceModel>) {
    guard !currencyCode.isEmpty else {
      completion(.failure(TLError.invalidCurrencyCode))
      return
    }
    getUserBalance { result in
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
  }
  
  func getUserBalance(completion: @escaping CompletionResultHandler<BalanceInfoModel>) {
    let router = PaymentRouter.getUserBalanceByCurrencyCode
    serverClient.performRequestWithBaseResponseDecodableModel(router: router, completion: completion)
  }
  
  func renamePaymentMethod(withNewName name: String, byId id: String, completion: @escaping CompletionResultHandler<EmptyModel>) {
    let router = PaymentRouter.renamePaymentMethod(newName: name, id: id)
    serverClient.performRequestWithBaseResponseDecodableModel(router: router, completion: completion)
  }
  
  func deletePaymentMethod(with id: String, completion: @escaping CompletionResultHandler<EmptyModel>) {
    let router = PaymentRouter.deletePaymentMethod(id: id)
    serverClient.performRequestWithBaseResponseDecodableModel(router: router, completion: completion)
  }
  
  func getInvoiceDetails(with id: String, completion: @escaping CompletionResultHandler<InvoiceDetailsModel>) {
    let router = InvoiceRouter.getInvoiceDetails(id: id)
    serverClient.performRequestWithBaseResponseDecodableModel(router: router, completion: completion)
  }
  
  func createInvoice(withId id: String, isEscrow: Bool, paymentMethods: [PaymentMethodModel], completion: @escaping CompletionResultHandler<InvoiceModel>) {
    let model = CreateInvoiceModel(invoiceId: id, paymentMethods: paymentMethods.toNilIfEmpty())
    let router = InvoiceRouter.createInvoice(isEscrow: isEscrow, model: model)
    serverClient.performRequestWithBaseResponseDecodableModel(router: router, completion: completion)
  }
  
  func payInvoice(withId id: String, isEscrow: Bool, completion: @escaping CompletionResultHandler<EmptyModel>) {
    let router = InvoiceRouter.payInvoice(id: id, isEscrow: isEscrow)
    serverClient.performRequestWithBaseResponseDecodableModel(router: router, completion: completion)
  }
  
  func getTransactionDetails(with id: String, completion: @escaping CompletionResultHandler<TransactionDetailsModel>) {
    let router = InvoiceRouter.getTransactionDetails(id: id)
    serverClient.performRequestWithBaseResponseDecodableModel(router: router, completion: completion)
  }
  
  func sendTransactionReceipt(withId id: String, email: String, completion: @escaping CompletionResultHandler<EmptyModel>) {
    let router = InvoiceRouter.sendTransactionReceipt(id: id, email: email)
    serverClient.performRequestWithBaseResponseDecodableModel(router: router, completion: completion)
  }
  
  func getTransactionHistory(withLimit limit: Int, offset: Int, sectionType: TransactionHistorySectionTypeModel, completion: @escaping CompletionResultHandler<TransactionHistoryModel>) {
    let model = GetTransactionHistoryModel(limit: limit, offset: offset, sectionType: sectionType)
    let router = InvoiceRouter.getTransactionHistory(model: model)
    serverClient.performRequestWithBaseResponseDecodableModel(router: router, completion: completion)
  }
  
  func getAddCreditCardRedirectUrl(completion: @escaping CompletionResultHandler<RedirectUrlModel>) {
    let router = AuthRouter.getAddCreditCardRedirectUrl
    serverClient.performRequestWithBaseResponseDecodableModel(router: router, completion: completion)
  }
  
  func submitKyc(with model: SubmitKycModel, completion: @escaping CompletionResultHandler<SubmittedKycModel>) {
    let router = KycRouter.submit(model)
    serverClient.performRequestWithBaseResponseDecodableModel(router: router, completion: completion)
  }
  
  func getSubmittedKycStatus(with id: String, completion: @escaping CompletionResultHandler<SubmittedKycStatusModel>) {
    let router = KycRouter.getStatus(id)
    serverClient.performRequestWithBaseResponseDecodableModel(router: router, completion: completion)
  }
  
  func getSettings(completion: @escaping CompletionResultHandler<SettingsModel>) {
    let router = SettingsRouter.getSettings
    serverClient.performRequestWithOriginalDecodableModel(router: router, completion: completion)
  }
  
}

// MARK: - For Testing

extension NetworkManager {
  
  func setServerClient(_ serverClient: ServerClientProtocol) {
    self.serverClient = serverClient
  }
  
}
