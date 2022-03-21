//
//  BaseResponse.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 21.03.2022.
//

import Foundation

struct BaseResponse<T: Decodable> {
  
  let result: Result<T, Error>
  
  var model: T? {
    switch result {
    case .success(let model): return model
    case .failure: return nil
    }
  }
  
  var error: Error? {
    switch result {
    case .failure(let error): return error
    case .success: return nil
    }
  }
  
  init(from jsonData: Any?) throws {
    guard let jsonData = jsonData else { throw TLError.serverBaseResponseIsNil }
    guard let dictionary = jsonData as? [String: Any] else { throw TLError.serverBaseResponseDecodingFailed }
    guard let statusStr = dictionary["status"] as? String, let status = Status(rawValue: statusStr) else { throw TLError.serverBaseResponseDecodingFailed }
    let payload = dictionary["payload"]
    if status == .failure, let object = try? ServerError.decodeObject(from: payload) {
      self.result = .failure(TLError.serverError(object.error))
    } else if status == .success, let object = try? T.decodeObject(from: payload) {
      self.result = .success(object)
    } else {
      throw TLError.serverBaseResponseDecodingFailed
    }
  }
  
}

private extension BaseResponse {
  
  enum Status: String {
    case success = "Success"
    case failure = "Failure"
  }
  
  struct ServerError: Decodable {
    let error: String
  }
  
}
