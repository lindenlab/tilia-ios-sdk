//
//  BalanceModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 22.03.2022.
//

import Foundation

struct BalanceModel: Decodable {
  
  let balance: Double
  let description: String
  
  private enum CodingKeys: String, CodingKey {
    case balance
    case description = "display"
  }
  
}

struct BalancesModel: Decodable {
  
  let balances: [String: SpendableModel]
  
}

struct SpendableModel: Decodable {
  
  let spendable: BalanceModel
  
}
