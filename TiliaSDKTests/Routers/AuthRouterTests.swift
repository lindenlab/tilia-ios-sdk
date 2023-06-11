//
//  AuthRouterTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 27.10.2022.
//

import XCTest
@testable import TiliaSDK

final class AuthRouterTests: XCTestCase {
  
  func testGetAddCreditCardRedirectUrl() {
    let router = AuthRouter.getAddCreditCardRedirectUrl
    TLManager.shared.setToken(UUID().uuidString)
    XCTAssertEqual(router.method, .post)
    XCTAssertNil(router.queryParameters)
    XCTAssertNotNil(router.bodyParameters)
    XCTAssertEqual(router.service, "auth")
    XCTAssertEqual(router.endpoint, "/authorize/user")
    XCTAssertEqual(router.testData?.count, router.readJSONFromFile("GetAddPaymentMethodRedirectUrlResponse")?.count)
    XCTAssertNotNil(try? router.requestHeaders())
    XCTAssertNotNil(try? router.asURLRequest())
  }
  
  func testGetAddPaypalRedirectUrl() {
    let router = AuthRouter.getPaypalRedirectUrl
    TLManager.shared.setToken(UUID().uuidString)
    XCTAssertEqual(router.method, .post)
    XCTAssertNil(router.queryParameters)
    XCTAssertNotNil(router.bodyParameters)
    XCTAssertEqual(router.service, "auth")
    XCTAssertEqual(router.endpoint, "/authorize/user")
    XCTAssertEqual(router.testData?.count, router.readJSONFromFile("GetAddPaymentMethodRedirectUrlResponse")?.count)
    XCTAssertNotNil(try? router.requestHeaders())
    XCTAssertNotNil(try? router.asURLRequest())
  }
  
}
