//
//  ServerTestClient.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 11.04.2022.
//

import Alamofire

enum ServerTestClient: ServerClientProtocol {
  
  static func performRequestWithDecodableModel<DataType>(router: RouterProtocol, completion: @escaping CompletionResultHandler<DataType>) where DataType : Decodable {
    if let data = router.testData {
      do {
        let baseModel = try BaseResponse<DataType>.decodeObject(from: data)
        if let model = baseModel.model {
          completion(.success(model))
        } else {
          completion(.failure(TLError.decodableDataIsNil))
        }
      } catch {
        completion(.failure(error))
      }
    } else {
      completion(.failure(TLError.decodableDataIsNil))
    }
  }
  
}
