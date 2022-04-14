//
//  ServerClient.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Alamofire

typealias CompletionResultHandler<T> = (Result<T, Error>) -> Void

protocol ServerClientProtocol {
  func performRequestWithDecodableModel<DataType: Decodable>(router: RouterProtocol, completion: @escaping CompletionResultHandler<DataType>)
}

struct ServerClient: ServerClientProtocol {
  
  func performRequestWithDecodableModel<DataType: Decodable>(router: RouterProtocol, completion: @escaping CompletionResultHandler<DataType>) {
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
