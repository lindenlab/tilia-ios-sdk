//
//  UIView+Helpers.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 09.05.2022.
//

import UIKit

extension UIView {
  
  func addClosingKeyboardOnTap() {
    let closeTap = UITapGestureRecognizer(target: self, action: #selector(UIView.endEditing(_:)))
    closeTap.cancelsTouchesInView = false
    addGestureRecognizer(closeTap)
  }
  
}
