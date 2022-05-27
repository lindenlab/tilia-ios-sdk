//
//  BaseResponse.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 21.03.2022.
//

import Foundation

struct BaseResponse<T: Decodable>: Decodable {
  
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
  
  private enum CodingKeys: String, CodingKey {
    case status
    case payload
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let status = try container.decode(Status.self, forKey: .status)
    switch status {
    case .success:
      let model = try container.decode(T.self, forKey: .payload)
      self.result = .success(model)
    case .failure:
      let error = try container.decode(ServerError.self, forKey: .payload)
      self.result = .failure(TLError.serverError(error.error))
    }
  }
  
}

private extension BaseResponse {
  
  enum Status: String, Decodable {
    case success = "Success"
    case failure = "Failure"
  }
  
  struct ServerError: Decodable {
    let error: String
  }
  
}
