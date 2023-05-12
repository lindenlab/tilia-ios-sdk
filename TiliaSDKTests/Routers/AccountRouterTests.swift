//
//  AccountRouterTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 27.10.2022.
//

import XCTest
@testable import TiliaSDK

final class AccountRouterTests: XCTestCase {
  
  func testGetTosRequiredForUser() {
    let router = AccountRouter.getTosRequiredForUser
    TLManager.shared.setToken(UUID().uuidString)
    XCTAssertEqual(router.method, .get)
    XCTAssertNil(router.queryParameters)
    XCTAssertNil(router.bodyParameters)
    XCTAssertEqual(router.service, "accounts")
    XCTAssertEqual(router.endpoint, "/v1/user-info/tos/tilia")
    XCTAssertEqual(router.testData?.count, router.readJSONFromFile("GetTosRequiredForUserResponse")?.count)
    XCTAssertNotNil(try? router.requestHeaders())
    XCTAssertNotNil(try? router.asURLRequest())
  }
  
  func testGetTosContent() {
    let router = AccountRouter.getTosContent
    XCTAssertEqual(router.method, .get)
    XCTAssertNil(router.queryParameters)
    XCTAssertNil(router.bodyParameters)
    XCTAssertEqual(router.service, "accounts")
    XCTAssertEqual(router.endpoint, "/v1/tos")
    XCTAssertEqual(router.testData?.count, router.readJSONFromFile("GetTosContentResponse")?.count)
    XCTAssertTrue((try? router.requestHeaders())?.isEmpty ?? false)
    XCTAssertNotNil(try? router.asURLRequest())
  }
  
  func testSignTosForUser() {
    let router = AccountRouter.signTosForUser
    TLManager.shared.setToken(UUID().uuidString)
    XCTAssertEqual(router.method, .post)
    XCTAssertNil(router.queryParameters)
    XCTAssertNil(router.bodyParameters)
    XCTAssertEqual(router.service, "accounts")
    XCTAssertEqual(router.endpoint, "/v1/user-info/tos/tilia")
    XCTAssertEqual(router.testData?.count, router.readJSONFromFile("SignTosForUserResponse")?.count)
    XCTAssertNotNil(try? router.requestHeaders())
    XCTAssertNotNil(try? router.asURLRequest())
  }
  
}
