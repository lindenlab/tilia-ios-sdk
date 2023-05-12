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
  
  func testErrorServerClientWithBaseResponseDecodableModel() {
    var errorModel: Error?
    let serverClient = ServerClient()
    let router = TestRouter()
    let expectation = XCTestExpectation(description: "testErrorServerClientWithBaseResponseDecodableModel")
    TLManager.shared.setToken("")
    serverClient.performRequestWithBaseResponseDecodableModel(router: router) { (result: Result<EmptyModel, Error>) in
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
  
  func testSuccessServerTestClientWithBaseResponseDecodableModel() {
    var emptyModel: EmptyModel?
    let serverClient = ServerTestClient()
    let router = TestRouter()
    let expectation = XCTestExpectation(description: "testSuccessServerTestClientWithBaseResponseDecodableModel")
    TLManager.shared.setToken(UUID().uuidString)
    serverClient.performRequestWithBaseResponseDecodableModel(router: router) { (result: Result<EmptyModel, Error>) in
      emptyModel = try? result.get()
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 2)
    XCTAssertNotNil(emptyModel)
  }
  
  func testErrorServerTestClientWithBaseResponseDecodableModel() {
    var errorModel: Error?
    let serverClient = ServerTestClient()
    let router = TestRouter()
    let expectation = XCTestExpectation(description: "testErrorServerTestClientWithBaseResponseDecodableModel")
    TLManager.shared.setToken("")
    serverClient.performRequestWithBaseResponseDecodableModel(router: router) { (result: Result<EmptyModel, Error>) in
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
  
  func testErrorServerClientWithOriginalDecodableModel() {
    var errorModel: Error?
    let serverClient = ServerClient()
    let router = TestRouter()
    let expectation = XCTestExpectation(description: "testErrorServerClientWithOriginalDecodableModel")
    TLManager.shared.setToken("")
    serverClient.performRequestWithOriginalDecodableModel(router: router) { (result: Result<EmptyModel, Error>) in
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
  
  func testSuccessServerTestClientWithOriginalDecodableModel() {
    var emptyModel: EmptyModel?
    let serverClient = ServerTestClient()
    let router = TestRouter()
    let expectation = XCTestExpectation(description: "testSuccessServerTestClientWithOriginalDecodableModel")
    TLManager.shared.setToken(UUID().uuidString)
    serverClient.performRequestWithOriginalDecodableModel(router: router) { (result: Result<EmptyModel, Error>) in
      emptyModel = try? result.get()
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 2)
    XCTAssertNotNil(emptyModel)
  }
  
  func testErrorServerTestClientWithOriginalDecodableModel() {
    var errorModel: Error?
    let serverClient = ServerTestClient()
    let router = TestRouter()
    let expectation = XCTestExpectation(description: "testErrorServerTestClientWithOriginalDecodableModel")
    TLManager.shared.setToken("")
    serverClient.performRequestWithOriginalDecodableModel(router: router) { (result: Result<EmptyModel, Error>) in
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
