//
//  SubmittedKycModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 13.07.2022.
//

import Foundation

struct SubmittedKycModel: Decodable {
  
  private enum CodingKeys: String, CodingKey {
    case kycId = "kyc_id"
  }
  
  let kycId: String
  
}
