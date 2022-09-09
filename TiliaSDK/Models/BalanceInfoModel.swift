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

struct PaymentMethodModel: Codable, Equatable {
  
  let id: String
  let display: String
  let type: PaymentTypeModel
  
  private enum DecodingKeys: String, CodingKey {
    case id
    case display = "display_string"
    case provider
    case methodClass = "method_class"
  }
  
  private enum EncodingKeys: String, CodingKey {
    case id = "payment_method_id"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DecodingKeys.self)
    self.id = try container.decode(String.self, forKey: .id)
    self.display = try container.decode(String.self, forKey: .display)
    // Check if this is a wallet
    if let type = try? container.decode(PaymentTypeModel.self, forKey: .provider) {
      self.type = type
    } else {
      self.type = try container.decode(PaymentTypeModel.self, forKey: .methodClass)
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: EncodingKeys.self)
    try container.encode(id, forKey: .id)
  }
  
}

enum PaymentTypeModel: String, Decodable {
  
  case wallet
  case paypal
  case americanExpress = "american-express"
  case discover
  case dinersClub = "diners-club"
  case jcb
  case maestro
  case electron
  case masterCard = "master-card"
  case visa
  case chinaUnionpay = "china-unionpay"
  
  var isWallet: Bool { return self == .wallet }
  
}
