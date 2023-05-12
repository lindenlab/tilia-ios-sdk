//
//  SettingsModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 12.05.2023.
//

import Foundation

struct SettingsModel: Decodable {
  
  private enum CodingKeys: String, CodingKey {
    case kyc = "KYC"
  }
  
  let kyc: KycSettingsModel
  
}

struct KycSettingsModel: Decodable {
  
  let countriesNotRequiringAddressDocuments: [String]
  
}
