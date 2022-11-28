//
//  KycRouterTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 27.10.2022.
//

import XCTest
@testable import TiliaSDK

final class KycRouterTests: XCTestCase {
  
  func testSubmit() {
    let model = SubmitKycModel(userInfoModel: .init(), userDocumentsModel: nil)
    let router = KycRouter.submit(model)
    TLManager.shared.setToken(UUID().uuidString)
    XCTAssertEqual(router.method, .post)
    XCTAssertNil(router.queryParameters)
    XCTAssertNotNil(router.bodyParameters)
    XCTAssertEqual(router.service, "pii")
    XCTAssertEqual(router.endpoint, "/v2/kyc")
    XCTAssertEqual(router.testData?.count, router.readJSONFromFile("SubmitKycResponse")?.count)
    XCTAssertNotNil(try? router.requestHeaders())
    XCTAssertNotNil(try? router.asURLRequest())
  }
  
  func testGetStatus() {
    let router = KycRouter.getStatus(UUID().uuidString)
    TLManager.shared.setToken(UUID().uuidString)
    XCTAssertEqual(router.method, .get)
    XCTAssertNotNil(router.queryParameters)
    XCTAssertNil(router.bodyParameters)
    XCTAssertEqual(router.service, "pii")
    XCTAssertEqual(router.endpoint, "/v2/kyc")
    XCTAssertEqual(router.testData?.count, router.readJSONFromFile("GetKycStatusResponse")?.count)
    XCTAssertNotNil(try? router.requestHeaders())
    XCTAssertNotNil(try? router.asURLRequest())
  }
  
}
