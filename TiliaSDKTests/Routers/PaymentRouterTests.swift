//
//  PaymentRouterTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 27.10.2022.
//

import XCTest
@testable import TiliaSDK

final class PaymentRouterTests: XCTestCase {
  
  func testGetUserBalanceByCurrencyCode() {
    let router = PaymentRouter.getUserBalanceByCurrencyCode
    TLManager.shared.setToken(UUID().uuidString)
    XCTAssertEqual(router.method, .get)
    XCTAssertNotNil(router.queryParameters)
    XCTAssertNil(router.bodyParameters)
    XCTAssertEqual(router.service, "payments")
    XCTAssertEqual(router.endpoint, "/transaction-methods")
    XCTAssertEqual(router.testData?.count, router.readJSONFromFile("GetUserBalanceByCurrencyCodeResponse")?.count)
    XCTAssertNotNil(try? router.requestHeaders())
    XCTAssertNotNil(try? router.asURLRequest())
  }
  
  func testRenamePaymentMethod() {
    let id = UUID().uuidString
    let router = PaymentRouter.renamePaymentMethod(newName: "newName", id: id)
    TLManager.shared.setToken(UUID().uuidString)
    XCTAssertEqual(router.method, .patch)
    XCTAssertNil(router.queryParameters)
    XCTAssertNotNil(router.bodyParameters)
    XCTAssertEqual(router.service, "payments")
    XCTAssertEqual(router.endpoint, "/v1/payment_method/\(id)")
    XCTAssertEqual(router.testData?.count, router.readJSONFromFile("EmptySuccessResponse")?.count)
    XCTAssertNotNil(try? router.requestHeaders())
    XCTAssertNotNil(try? router.asURLRequest())
  }
  
  func testDeletePaymentMethod() {
    let id = UUID().uuidString
    let router = PaymentRouter.deletePaymentMethod(id: id)
    TLManager.shared.setToken(UUID().uuidString)
    XCTAssertEqual(router.method, .delete)
    XCTAssertNil(router.queryParameters)
    XCTAssertNil(router.bodyParameters)
    XCTAssertEqual(router.service, "payments")
    XCTAssertEqual(router.endpoint, "/v1/payment_method/\(id)")
    XCTAssertEqual(router.testData?.count, router.readJSONFromFile("EmptySuccessResponse")?.count)
    XCTAssertNotNil(try? router.requestHeaders())
    XCTAssertNotNil(try? router.asURLRequest())
  }
  
}
