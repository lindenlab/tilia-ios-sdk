//
//  FinishVerifyUserEmailModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 15.05.2023.
//

import Foundation

struct FinishVerifyUserEmailModel: Encodable {
  
  let code: String
  let nonce: String
  
}
