//
//  BalanceInfoModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 22.03.2022.
//

import Foundation

struct BalanceInfoModel: Decodable {
  
  let balances: [String: SpendableModel]
  let paymentMethods: [CheckoutPaymentMethodModel]
  
  private enum CodingKeys: String, CodingKey {
    case balances
    case paymentMethods = "payment_methods"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.balances = try container.decode([String: SpendableModel].self, forKey: .balances)
    let paymentMethods = try container.decode([String: CheckoutPaymentMethodModel].self, forKey: .paymentMethods)
    self.paymentMethods = paymentMethods.values.sorted { $0.type.isWallet && !$1.type.isWallet }
  }
  
}

struct SpendableModel: Decodable {
  
  let spendable: BalanceModel
  
}

struct BalanceModel: Decodable {
  
  let balance: Double
  let display: String
  
}
