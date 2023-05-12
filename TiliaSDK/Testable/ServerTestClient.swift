//
//  ServerTestClient.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 11.04.2022.
//

import Alamofire

struct ServerTestClient: ServerClientProtocol {
  
  func performRequestWithBaseResponseDecodableModel<DataType: Decodable>(router: RouterProtocol, completion: @escaping CompletionResultHandler<DataType>) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      do {
        let _ = try router.requestHeaders()
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
      } catch {
        completion(.failure(error))
      }
    }
  }
  
  func performRequestWithOriginalDecodableModel<DataType: Decodable>(router: RouterProtocol, completion: @escaping CompletionResultHandler<DataType>) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      do {
        let _ = try router.requestHeaders()
        if let data = router.testData {
          do {
            let model = try DataType.decodeObject(from: data)
            completion(.success(model))
          } catch {
            completion(.failure(error))
          }
        } else {
          completion(.failure(TLError.decodableDataIsNil))
        }
      } catch {
        completion(.failure(error))
      }
    }
  }
  
}

extension TLManager {
  
  func setIsTestServer(_ isTest: Bool) {
    networkManager.setServerClient(isTest ? ServerTestClient() : ServerClient())
  }
  
}
