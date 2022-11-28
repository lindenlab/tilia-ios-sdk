//
//  CollectionTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 27.10.2022.
//

import XCTest
@testable import TiliaSDK

final class CollectionTests: XCTestCase {
  
  func testSafety() {
    let array = [1, 2, 3]
    XCTAssertEqual(array[safe: 2], 3)
    XCTAssertNil(array[safe: 5])
  }
  
}
