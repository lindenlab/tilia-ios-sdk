//
//  SubmittedKycStatusModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 13.07.2022.
//

import Foundation

struct SubmittedKycStatusModel: Decodable {
  
  let state: SubmittedKycStateModel
  
}

enum SubmittedKycStateModel: String, Decodable {
  
  case noData = "NODATA"
  case accepted = "ACCEPT"
  case denied = "DENY"
  case needManualReview = "MANUAL_REVIEW"
  case needReverify = "REVERIFY"
  
}
