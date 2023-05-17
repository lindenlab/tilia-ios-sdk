//
//  VerifyEmailValidator.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 17.05.2023.
//

import Foundation

struct VerifyEmailValidator {
  
  func isCodeValid(_ code: String) -> Bool {
    return code.count == 6
  }
  
  func canEnterMore(_ code: String) -> Bool {
    return code.count <= 6
  }
  
}
