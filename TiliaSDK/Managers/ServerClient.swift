//
//  ServerClient.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Alamofire

typealias CompletionResultHandler<T> = (Result<T, Error>) -> Void

enum ServerClient {
  
  static func performRequestWithDecodableModel<DataType: Decodable>(router: URLRequestConvertible, completion: @escaping CompletionResultHandler<DataType>) {
    // TODO: - Maybe here we need to check response for some custom error etc
    AF.request(router).validate().responseDecodable(of: DataType.self) { response in
      switch response.result {
      case .success(let model):
        completion(.success(model))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
}
