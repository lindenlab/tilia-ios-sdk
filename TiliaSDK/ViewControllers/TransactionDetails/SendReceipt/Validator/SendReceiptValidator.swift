//
//  SendReceiptValidator.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 26.08.2022.
//

import Foundation

enum SendReceiptValidator {
  
  static func isEmailValid(_ inputString: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: inputString)
  }
  
}
