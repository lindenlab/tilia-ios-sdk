//
//  XCTestCase+Extensions.swift
//  TiliaSDKUITests
//
//  Created by Serhii.Petrishenko on 07.09.2022.
//

import XCTest

extension XCTestCase {
  
  func scrollUp(app: XCUIApplication, dy: CGFloat, startElement: XCUIElement) {
    let startCoordinate = startElement.coordinate(withNormalizedOffset: .zero)
    let endCoordinate = startCoordinate.withOffset(CGVector(dx: 0.0, dy: dy))
    startCoordinate.press(forDuration: 0.1, thenDragTo: endCoordinate)
  }
  
}
