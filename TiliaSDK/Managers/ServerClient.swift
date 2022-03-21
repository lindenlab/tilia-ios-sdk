//
//  ServerClient.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Alamofire

enum ServerClient {
  
  static func performRequestWithDecodableModel<DataType: Decodable>(router: URLRequestConvertible, completion: @escaping CompletionResultHandler<DataType>) {
    AF.request(router).validate().responseJSON { response in
      switch response.result {
      case .success(let data):
        do {
          let baseResponse = try BaseResponse<DataType>(from: data)
          switch baseResponse.result {
          case .success(let model):
            completion(.success(model))
          case .failure(let error):
            completion(.failure(error))
          }
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        if let serverError = (try? BaseResponse<DataType>(from: response.data?.simpleSerialize))?.error {
          completion(.failure(serverError))
        } else {
          completion(.failure(error))
        }
      }
    }
  }
  
}
