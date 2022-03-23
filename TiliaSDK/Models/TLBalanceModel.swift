//
//  TLBalanceModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 22.03.2022.
//

import Foundation

struct BalancesModel: Decodable {
  
  let balances: [String: SpendableModel]
  
}

struct SpendableModel: Decodable {
  
  let spendable: TLBalanceModel
  
}

public struct TLBalanceModel: Decodable {
  
  public let balance: Double
  public let description: String
  
  private enum CodingKeys: String, CodingKey {
    case balance
    case description = "display"
  }
  
}
