//
//  XCTestCase+Extensions.swift
//  TiliaSDKUITests
//
//  Created by Serhii.Petrishenko on 07.09.2022.
//

import XCTest

extension XCTestCase {
  
  func scrollUp(app: XCUIApplication, dy: CGFloat) {
    let visibleCells = app.tables.cells
    let startCoordinate = visibleCells.element(boundBy: visibleCells.count - 1).coordinate(withNormalizedOffset: .zero)
    let endCoordinate = startCoordinate.withOffset(CGVector(dx: 0.0, dy: dy))
    startCoordinate.press(forDuration: 0.1, thenDragTo: endCoordinate)
  }
  
}
