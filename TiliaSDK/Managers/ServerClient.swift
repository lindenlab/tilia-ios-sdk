//
//  ServerClient.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Alamofire

typealias CompletionResultHandler<T> = (Result<T, Error>) -> Void

enum ServerClient {
  
  static func getTosRequiredForUser(completion: @escaping CompletionResultHandler<TosModel>) {
    let router = AccountRouter.getTosRequiredForUser
    Self.performRequestWithDecodableModel(router: router, completion: completion)
  }
  
  static func signTosForUser(completion: @escaping CompletionResultHandler<EmptyModel>) {
    let router = AccountRouter.signTosForUser
    Self.performRequestWithDecodableModel(router: router, completion: completion)
  }
  
  static func getUserBalanceByCurrencyCode(_ currencyCode: String, completion: @escaping CompletionResultHandler<BalanceModel>) {
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
    Self.performRequestWithDecodableModel(router: router, completion: completionHandler)
  }
  
}

// MARK: - Private Methods

private extension ServerClient {
  
  static func performRequestWithDecodableModel<DataType: Decodable>(router: URLRequestConvertible, completion: @escaping CompletionResultHandler<DataType>) {
    AF.request(router).validate().responseDecodable(of: BaseResponse<DataType>.self) { response in
      switch response.result {
      case .success(let baseResponse):
        switch baseResponse.result {
        case .success(let model):
          completion(.success(model))
        case .failure(let error):
          completion(.failure(error))
        }
      case .failure(let error):
        if let serverError = (try? BaseResponse<DataType>.decodeObject(from: response.data))?.error {
          completion(.failure(serverError))
        } else {
          completion(.failure(error))
        }
      }
    }
  }
  
}
