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
  var queryParameters: Parameters? { get }
  var bodyParameters: Parameters? { get }
  var service: String { get }
  var endpoint: String { get }
  var testData: Data? { get } // Only for Unit Tests
  
  func requestHeaders() throws -> [String: String]
}

// MARK: - Default Implementation

extension RouterProtocol {
  
  var serverConfiguration: ServerConfiguration {
    return TLManager.shared.networkManager.serverConfiguration
  }
  
  var queryParameters: Parameters? { return nil }
  
  var bodyParameters: Parameters? { return nil }
  
  func defaultRequestHeaders() throws -> [String: String] {
    guard let token = serverConfiguration.token, !token.isEmpty else { throw TLError.invalidToken }
    let headers = [
      "Content-Type": "application/json",
      "Authorization": "Bearer \(token)"
    ]
    return headers
  }
  
  func requestHeaders() throws -> [String: String] {
    return try defaultRequestHeaders()
  }
  
  func asURLRequest() throws -> URLRequest {
    let path = "https://\(service).\(serverConfiguration.environment.description).com\(endpoint)"
    let escapedPath = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed.union(CharacterSet.urlQueryAllowed)) ?? ""
    let url = try escapedPath.asURL()
    
    var urlRequest = try URLEncoding.default.encode(URLRequest(url: url), with: queryParameters)
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

// MARK: - Helpers for Unit Tests

extension RouterProtocol {
  
  func readJSONFromFile(_ fileName: String) -> Data? {
    guard
      let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
      let data = try? Data(contentsOf: url, options: .mappedIfSafe) else { return nil }
    return data
  }
  
}
