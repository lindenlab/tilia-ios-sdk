//
//  BalanceInfoModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 22.03.2022.
//

import Foundation

struct BalanceInfoModel: Decodable {
  
  let balances: [String: SpendableModel]
  let paymentMethods: [PaymentMethodModel]
  
  private enum CodingKeys: String, CodingKey {
    case balances
    case paymentMethods = "payment_methods"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.balances = try container.decode([String: SpendableModel].self, forKey: .balances)
    let paymentMethods = try container.decode([String: PaymentMethodModel].self, forKey: .paymentMethods)
    self.paymentMethods = Array(paymentMethods.values)
  }
  
}

struct SpendableModel: Decodable {
  
  let spendable: BalanceModel
  
}

struct BalanceModel: Decodable {
  
  let balance: Double
  let display: String
  
}

struct PaymentMethodModel: Decodable {
  
  let id: String
  let display: String
  
  private enum CodingKeys: String, CodingKey {
    case id
    case display = "display_string"
  }
  
}
