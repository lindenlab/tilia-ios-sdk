//
//  XCTestCase+Extensions.swift
//  TiliaSDKUITests
//
//  Created by Serhii.Petrishenko on 07.09.2022.
//

import XCTest

extension XCTestCase {
  
  func scrollUp(app: XCUIApplication, dy: CGFloat, startElement: XCUIElement? = nil) {
    guard let startElement = startElement ?? firstVisibleCell(in: app) else { return }
    let startCoordinate = startElement.coordinate(withNormalizedOffset: .init(dx: 0, dy: 1))
    let endCoordinate = startCoordinate.withOffset(.init(dx: 0.0, dy: dy))
    startCoordinate.press(forDuration: 0.1, thenDragTo: endCoordinate)
  }
  
  func firstVisibleCell(in app: XCUIApplication) -> XCUIElement? {
    var element: XCUIElement?
    let cells = app.tables.cells
    for i in 0..<cells.count {
      let firstElement = cells.element(boundBy: i)
      if firstElement.isHittable && firstElement.frame.minY >= 0 {
        element = firstElement
        break
      }
    }
    return element
  }
  
  func closeKeyboard(app: XCUIApplication) {
    let returnButton = app.keyboards.buttons["return"]
    XCTAssert(returnButton.exists)
    returnButton.tap()
  }
  
  func wait(duration: TimeInterval) {
    let _ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: duration)
  }
  
}
