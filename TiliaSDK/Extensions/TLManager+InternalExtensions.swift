//
//  TLManager+InternalExtensions.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import Foundation

extension TLManager {
  
  func getTos(completion: @escaping CompletionResultHandler<TosModel>) {
    ServerClient.getTosRequiredForUser(completion: completion)
  }
  
  func signTos(compeltion: @escaping CompletionResultHandler<EmptyModel>) {
    ServerClient.signTosForUser(completion: compeltion)
  }
  
  func getBalanceByCurrencyCode(_ currencyCode: String,
                                completion: @escaping CompletionResultHandler<BalanceModel>) {
    ServerClient.getUserBalanceByCurrencyCode(currencyCode, completion: completion)
  }
  
  func getInvoiceDetails(with id: String,
                         completion: @escaping CompletionResultHandler<InvoiceDetailsModel>) {
    ServerClient.getInvoiceDetails(with: id, completion: completion)
  }
  
  func createInvoice(withId id: String,
                     isEscrow: Bool,
                     completion: @escaping CompletionResultHandler<InvoiceModel>) {
    ServerClient.createInvoice(withId: id, isEscrow: isEscrow, completion: completion)
  }
  
  func payInvoice(withId id: String,
                  isEscrow: Bool,
                  completion: @escaping CompletionResultHandler<EmptyModel>) {
    ServerClient.payInvoice(withId: id, isEscrow: isEscrow, completion: completion)
  }
  
}
