//
//  EmailVerificationModeModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 18.05.2023.
//

import UIKit

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

extension EmailVerificationModeModel {
  
  var isTextFieldEditable: Bool {
    switch self {
    case .notVerified, .edit: return true
    case .verified: return false
    }
  }
  
  var isEditButtonHidden: Bool {
    switch self {
    case .verified:
      return false
    case .notVerified, .edit:
      return true
    }
  }
  
}
