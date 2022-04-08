//
//  BalanceModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 22.03.2022.
//

import Foundation

struct BalanceModel: Decodable {
  
  let balance: Double
  let display: String
  
}

struct BalancesModel: Decodable {
  
  let balances: [String: SpendableModel]
  
}

struct SpendableModel: Decodable {
  
  let spendable: BalanceModel
  
}
