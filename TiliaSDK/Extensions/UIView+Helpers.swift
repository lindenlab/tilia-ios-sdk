//
//  UIView+Helpers.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 09.05.2022.
//

import UIKit

extension UIView {
  
  var firstResponder: UIView? {
    if self.isFirstResponder {
      return self
    }
    for view in self.subviews {
      if let firstResponder = view.firstResponder {
        return firstResponder
      }
    }
    return nil
  }
  
  func addClosingKeyboardOnTap() {
    let closeTap = UITapGestureRecognizer(target: self, action: #selector(UIView.endEditing(_:)))
    closeTap.cancelsTouchesInView = false
    addGestureRecognizer(closeTap)
  }
  
}
