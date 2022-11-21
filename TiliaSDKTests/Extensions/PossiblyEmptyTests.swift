//
//  PossiblyEmptyTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 27.10.2022.
//

import XCTest
@testable import TiliaSDK

final class PossiblyEmptyTests: XCTestCase {
  
  func testToNilIfEmpty() {
    XCTAssertNil("".toNilIfEmpty())
    XCTAssertNotNil("Str".toNilIfEmpty())
    XCTAssertNil(0.toNilIfEmpty())
    XCTAssertNotNil(1.toNilIfEmpty())
    XCTAssertNil(0.0.toNilIfEmpty())
    XCTAssertNotNil(1.0.toNilIfEmpty())
    XCTAssertNil([].toNilIfEmpty())
    XCTAssertNotNil([1].toNilIfEmpty())
    XCTAssertNil(Set<Int>().toNilIfEmpty())
    XCTAssertNotNil(Set<Int>(arrayLiteral: 1).toNilIfEmpty())
    XCTAssertNil([:].toNilIfEmpty())
    XCTAssertNotNil(["key": 1].toNilIfEmpty())
    
    let empty: Int? = nil
    let nonEmpty: Int? = 1
    XCTAssertTrue(empty.isEmpty)
    XCTAssertFalse(nonEmpty.isEmpty)
  }
  
}
