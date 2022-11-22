//
//  XCUIElement+Etensions.swift
//  TiliaSDKUITests
//
//  Created by Serhii.Petrishenko on 22.11.2022.
//

import XCTest

extension XCUIElement {
  
  func tapUnhittable() {
    XCTContext.runActivity(named: "Tap \(self) by coordinate") { _ in
      coordinate(withNormalizedOffset: .zero).tap()
    }
  }
  
}
