//
//  PaymentMethodModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 25.08.2022.
//

import UIKit

struct PaymentMethodModel: Codable, Equatable, Hashable {
  
  let id: String
  let display: String
  let type: PaymentTypeModel
  var amount: Double?
  
  private enum DecodingKeys: String, CodingKey {
    case id
    case display = "display_string"
    case provider
    case methodClass = "method_class"
  }
  
  private enum EncodingKeys: String, CodingKey {
    case id = "payment_method_id"
    case isWallet
    case amount
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
    if let amount = amount {
      try container.encode(amount, forKey: .amount)
      try container.encode(type.isWallet, forKey: .isWallet)
    }
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
  case chinaUnionPay = "china-unionpay"
  
  var isWallet: Bool { return self == .wallet }
  
  var icon: UIImage? {
    switch self {
    case .wallet: return .walletIcon
    case .paypal: return .payPalIcon
    case .americanExpress: return .americanExpressIcon
    case .discover: return .discoverIcon
    case .dinersClub: return .dinersClubIcon
    case .jcb: return .jcbIcon
    case .maestro: return .maestroIcon
    case .electron: return nil
    case .masterCard: return .masterCardIcon
    case .visa: return .visaIcon
    case .chinaUnionPay: return .chinaUnionPayIcon
    }
  }
  
}
