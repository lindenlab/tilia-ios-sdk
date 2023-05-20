//
//  EmailVerificationModeModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 18.05.2023.
//

import Foundation

protocol EmailVerifiable {
  var email: String? { get }
  var emailVerificationMode: EmailVerificationModeModel { get }
}

extension EmailVerifiable {
  
  var emailVerificationMode: EmailVerificationModeModel {
    return email == nil ? .notVerified : .verified
  }
  
}

enum EmailVerificationModeModel {
  
  case notVerified
  case verified
  case edit
  
}
