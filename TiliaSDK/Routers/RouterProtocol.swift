//
//  RouterProtocol.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Alamofire

protocol RouterProtocol: URLRequestConvertible {
  var serverConfiguration: ServerConfiguration { get }
  var method: HTTPMethod { get }
  var bodyParameters: Parameters? { get }
  var service: String { get }
  var endpoint: String { get }
  
  func requestHeaders() throws -> [String: String?]
}

// MARK: - Default Implementation

extension RouterProtocol {
  
  var serverConfiguration: ServerConfiguration {
    return TLManager.shared.serverConfiguration
  }
  
  func requestHeaders() throws -> [String: String?] {
    guard let token = serverConfiguration.token, !token.isEmpty else { throw TLError.invalidToken }
    let headers = [
      "Content-Type": "application/json",
      "Authorization": "Bearer \(token)"
    ]
    return headers
  }
  
  func asURLRequest() throws -> URLRequest {
    let stringUrl = "https://\(service).\(serverConfiguration.environment.description).com\(endpoint)"
    let url = try stringUrl.asURL()
    
    var urlRequest = URLRequest(url: url)
    urlRequest.timeoutInterval = serverConfiguration.timeoutInterval
    urlRequest.httpMethod = method.rawValue
    
    let headers = try requestHeaders()
    headers.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
    
    if let bodyParameters = bodyParameters, method != .get {
      urlRequest.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters, options: [])
    }
    
    return urlRequest
  }
  
}
