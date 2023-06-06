//
//  LimitTextFieldDelegate.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 06.06.2023.
//

import UIKit

final class LimitTextFieldDelegate: NSObject, UITextFieldDelegate {
  
  private let limit: Int
  var textWillChangeAction: ((String) -> Void)?
  
  init(limit: Int) {
    self.limit = limit
    super.init()
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let newText = textField.text?.newString(forRange: range, withReplacementString: string) ?? ""
    let canEnter = newText.count <= limit
    if canEnter {
      textWillChangeAction?(newText)
    }
    return canEnter
  }
  
}
