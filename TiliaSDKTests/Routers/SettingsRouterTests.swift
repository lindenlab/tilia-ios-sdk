//
//  SettingsRouterTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 12.05.2023.
//

import XCTest
@testable import TiliaSDK

final class SettingsRouterTests: XCTestCase {
  
  func testGetSettings() {
    let router = SettingsRouter.getSettings
    XCTAssertEqual(router.method, .get)
    XCTAssertNil(router.queryParameters)
    XCTAssertNil(router.bodyParameters)
    XCTAssertEqual(router.service, "web")
    XCTAssertEqual(router.endpoint, "/ui/api/settings/acweb")
    XCTAssertEqual(router.testData?.count, router.readJSONFromFile("GetSettingsResponse")?.count)
    XCTAssertTrue((try? router.requestHeaders())?.isEmpty ?? false)
    XCTAssertNotNil(try? router.asURLRequest())
  }
  
}
