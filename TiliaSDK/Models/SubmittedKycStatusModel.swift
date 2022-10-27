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
  case processing = "PROCESSING"
  case accepted = "ACCEPT"
  case denied = "DENY"
  case manualReview = "MANUAL_REVIEW"
  case reverify = "REVERIFY"
  
}
