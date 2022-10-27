//
//  BaseRouterTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 27.10.2022.
//

import Alamofire
import XCTest
@testable import TiliaSDK

final class BaseRouterTests: XCTestCase {
  
  func testGetRouter() {
    let token = UUID().uuidString
    let interval = 20.0
    let environment = TLEnvironment.staging
    TLManager.shared.setToken(token)
    TLManager.shared.setTimeoutInterval(interval)
    TLManager.shared.setEnvironment(environment)
    let router = TestGetRouter()
    let headers = [
      "Content-Type": "application/json",
      "Authorization": "Bearer \(token)"
    ]
    let parameters = ["key": "value"]
    let service = "service"
    let endpoint = "/endpoint"
    let testData = router.readJSONFromFile("EmptySuccessResponse")
    let urlRequest = try? router.asURLRequest()
    let url = "https://service.staging.tilia-inc.com/endpoint?key=value"
    XCTAssertEqual(router.serverConfiguration.token, token)
    XCTAssertEqual(router.serverConfiguration.timeoutInterval, interval)
    XCTAssertEqual(router.serverConfiguration.environment, environment)
    XCTAssertEqual(router.method, .get)
    XCTAssertEqual(router.queryParameters as? [String: String], parameters)
    XCTAssertNil(router.bodyParameters)
    XCTAssertEqual(router.service, service)
    XCTAssertEqual(router.endpoint, endpoint)
    XCTAssertEqual(router.testData?.count, testData?.count)
    XCTAssertEqual(try? router.requestHeaders(), headers)
    XCTAssertEqual(try? router.requestHeaders(), try? router.defaultRequestHeaders())
    XCTAssertEqual(urlRequest?.url?.absoluteString, url)
    XCTAssertEqual(urlRequest?.timeoutInterval, interval)
    XCTAssertEqual(urlRequest?.httpMethod, HTTPMethod.get.rawValue)
    XCTAssertEqual(urlRequest?.allHTTPHeaderFields, headers)
    XCTAssertNil(urlRequest?.httpBody)
  }
  
  func testPostRouter() {
    let token = UUID().uuidString
    let interval = 20.0
    let environment = TLEnvironment.staging
    TLManager.shared.setToken(token)
    TLManager.shared.setTimeoutInterval(interval)
    TLManager.shared.setEnvironment(environment)
    let router = TestPostRouter()
    let headers = [
      "Content-Type": "application/json",
      "Authorization": "Bearer \(token)"
    ]
    let parameters = ["key": "value"]
    let service = "service"
    let endpoint = "/endpoint"
    let testData = router.readJSONFromFile("EmptySuccessResponse")
    let urlRequest = try? router.asURLRequest()
    let url = "https://service.staging.tilia-inc.com/endpoint"
    XCTAssertEqual(router.serverConfiguration.token, token)
    XCTAssertEqual(router.serverConfiguration.timeoutInterval, interval)
    XCTAssertEqual(router.serverConfiguration.environment, environment)
    XCTAssertEqual(router.method, .post)
    XCTAssertNil(router.queryParameters)
    XCTAssertEqual(router.bodyParameters as? [String: String], parameters)
    XCTAssertEqual(router.service, service)
    XCTAssertEqual(router.endpoint, endpoint)
    XCTAssertEqual(router.testData?.count, testData?.count)
    XCTAssertEqual(try? router.requestHeaders(), headers)
    XCTAssertEqual(try? router.requestHeaders(), try? router.defaultRequestHeaders())
    XCTAssertEqual(urlRequest?.url?.absoluteString, url)
    XCTAssertEqual(urlRequest?.timeoutInterval, interval)
    XCTAssertEqual(urlRequest?.httpMethod, HTTPMethod.post.rawValue)
    XCTAssertEqual(urlRequest?.allHTTPHeaderFields, headers)
    XCTAssertNotNil(urlRequest?.httpBody)
  }
  
}

// MARK: - Additional Helpers

private extension BaseRouterTests {
  
  struct TestGetRouter: RouterProtocol {
    
    var method: HTTPMethod { return .get }
    var queryParameters: Parameters? { return ["key": "value"] }
    var service: String { return "service" }
    var endpoint: String { return "/endpoint" }
    var testData: Data? { return readJSONFromFile("EmptySuccessResponse") }
    
  }
  
  struct TestPostRouter: RouterProtocol {
    
    var method: HTTPMethod { return .post }
    var bodyParameters: Parameters? { return ["key": "value"] }
    var service: String { return "service" }
    var endpoint: String { return "/endpoint" }
    var testData: Data? { return readJSONFromFile("EmptySuccessResponse") }
    
  }
  
}
