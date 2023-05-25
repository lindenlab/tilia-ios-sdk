//
//  EncodableTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 27.10.2022.
//

import XCTest
@testable import TiliaSDK

final class EncodableTests: XCTestCase {
  
  func testEncoding() {
    let model = Model(property: "Property")
    XCTAssertNotNil(model.encodedData)
    XCTAssertNotNil(model.encodedParameters)
    XCTAssertNotNil(model.jsonStr)
  }
  
}

// MARK: - Additional Helpers

private extension EncodableTests {
  
  struct Model: Encodable {
    let property: String
  }
  
}
