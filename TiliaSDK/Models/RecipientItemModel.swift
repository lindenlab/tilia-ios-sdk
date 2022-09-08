//
//  RecipientItemModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 07.09.2022.
//

import Foundation

struct RecipientItemModel: Decodable {
  
  let description: String
  let displayAmount: String
  let paymentMethodDescription: String
  let paymentMethodDisplayAmount: String
  
  private enum CodingKeys: String, CodingKey {
    case description
    case displayAmount = "amount_received_display"
    case paymentMethodDescription = "amount_received_less_fees_display"
    case paymentMethodDisplayAmount = "payment_method_display_string"
  }
  
}
