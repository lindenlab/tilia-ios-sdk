//
//  ServerClientTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 28.10.2022.
//

import Alamofire
import XCTest
@testable import TiliaSDK

final class ServerClientTests: XCTestCase {
  
  func testErrorServerClient() {
    var errorModel: Error?
    let serverClient = ServerClient()
    let router = TestRouter()
    let expectation = XCTestExpectation(description: "testErrorServerClient")
    TLManager.shared.setToken("")
    serverClient.performRequestWithDecodableModel(router: router) { (result: Result<EmptyModel, Error>) in
      switch result {
      case .success:
        break
      case .failure(let error):
        errorModel = error
        expectation.fulfill()
      }
    }
    wait(for: [expectation], timeout: 2)
    XCTAssertNotNil(errorModel)
  }
  
  func testSuccessServerTestClient() {
    var emptyModel: EmptyModel?
    let serverClient = ServerTestClient()
    let router = TestRouter()
    let expectation = XCTestExpectation(description: "testSuccessServerTestClient")
    TLManager.shared.setToken(UUID().uuidString)
    serverClient.performRequestWithDecodableModel(router: router) { (result: Result<EmptyModel, Error>) in
      emptyModel = try? result.get()
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 2)
    XCTAssertNotNil(emptyModel)
  }
  
  func testErrorServerTestClient() {
    var errorModel: Error?
    let serverClient = ServerTestClient()
    let router = TestRouter()
    let expectation = XCTestExpectation(description: "testErrorServerTestClient")
    TLManager.shared.setToken("")
    serverClient.performRequestWithDecodableModel(router: router) { (result: Result<EmptyModel, Error>) in
      switch result {
      case .success:
        break
      case .failure(let error):
        errorModel = error
        expectation.fulfill()
      }
    }
    wait(for: [expectation], timeout: 2)
    XCTAssertNotNil(errorModel)
  }
  
}

// MARK: - Additional Helpers

private extension ServerClientTests {
  
  struct TestRouter: RouterProtocol {
        
    var method: Alamofire.HTTPMethod { return .get }
    var service: String { return "service" }
    var endpoint: String { return "endpoint" }
    var testData: Data? { return readJSONFromFile("EmptySuccessResponse") }
    
  }
  
}
