//
//  TLManager+InternalExtensions.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import Foundation

// MARK: - Internal Methods

extension TLManager {
  
  func getTosModel(completion: @escaping CompletionResultHandler<TosModel>) {
    ServerClient.getTosRequiredForUser(completion: completion)
  }
  
  func getBalanceModelByCurrencyCode(_ currencyCode: String,
                                     completion: @escaping CompletionResultHandler<BalanceModel>) {
    ServerClient.getUserBalanceByCurrencyCode(currencyCode, completion: completion)
  }
  
}
