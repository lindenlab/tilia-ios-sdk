//
//  DecodableTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 27.10.2022.
//

import XCTest
@testable import TiliaSDK

final class DecodableTests: XCTestCase {
  
  func testDecodeObject() {
    let data = try? JSONEncoder().encode("{}")
    let model = try? EmptyModel.decodeObject(from: data)
    XCTAssertNotNil(model)
  }
  
}
