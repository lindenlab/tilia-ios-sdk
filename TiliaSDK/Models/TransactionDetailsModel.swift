//
//  TransactionDetailsModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 25.08.2022.
//

import Foundation

struct TransactionDetailsModel: Decodable {
  
  let id: String
  let type: TransactionType
  let role: TransactionRole
  let status: TransactionStatus
  let accountId: String
  let referenceType: String?
  let referenceId: String?
  let createDate: Date
  let total: String
  let subTotal: String?
  let tax: String?
  let items: [LineItemModel]
  let paymentMethods: [TransactionPaymentMethodModel]
  
  private enum CodingKeys: String, CodingKey {
    case id = "transaction_id"
    case type = "transaction_type"
    case role = "transaction_role"
    case status = "transaction_status"
    case accountId = "account_id"
    case referenceType = "reference_type"
    case referenceId = "reference_id"
    case createDate = "created"
    case summary
    case subTotal
    case tax
    case displayAmount = "display_amount"
    case data = "transaction_data"
    case items = "line_items"
    case paymentMethods = "payment_methods"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    type = try container.decode(TransactionType.self, forKey: .type)
    role = try container.decode(TransactionRole.self, forKey: .role)
    status = try container.decode(TransactionStatus.self, forKey: .status)
    accountId = try container.decode(String.self, forKey: .accountId)
    
    let items = try container.decode([String: LineItemModel].self, forKey: .items)
    self.items = items.values.sorted { $0.sortOrder ?? 0 < $1.sortOrder ?? 0 }
    
    let paymentMethods = try container.decode([String: TransactionPaymentMethodModel].self, forKey: .paymentMethods)
    self.paymentMethods = paymentMethods.values.sorted { $0.type.isWallet && !$1.type.isWallet }
    
    let dataContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
    referenceType = (try? dataContainer.decode(String.self, forKey: .referenceType))?.toNilIfEmpty()
    referenceId = (try? dataContainer.decode(String.self, forKey: .referenceId))?.toNilIfEmpty()
    
    let createDateString = try dataContainer.decode(String.self, forKey: .createDate)
    if let createDate = ISO8601DateFormatter().date(from: createDateString) {
      self.createDate = createDate
    } else {
      throw TLError.invalidDateFormatForString(createDateString)
    }
    
    let summaryContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .summary)
    total = try summaryContainer.decode(String.self, forKey: .displayAmount)
    
    let subTotalContainer = try summaryContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .subTotal)
    subTotal = (try subTotalContainer.decodeIfPresent(String.self, forKey: .displayAmount))?.toNilIfEmpty()
    
    let taxContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .tax)
    tax = (try taxContainer.decodeIfPresent(String.self, forKey: .displayAmount))?.toNilIfEmpty()
  }
  
}

enum TransactionType: String, Decodable {
  
  case userPurchase = "user_purchase"
  case userPurchaseRecipient = "user_purchase_recipient"
  
}

enum TransactionRole: String, Decodable {
  
  case buyer
  case seller
  
}

enum TransactionStatus: String, Decodable, CustomStringConvertible {
  
  case pending
  case processed
  case failed
  
  var description: String {
    switch self {
    case .pending: return L.pending
    case .processed: return L.processed
    case .failed: return L.failed
    }
  }
  
}

struct TransactionPaymentMethodModel: Decodable {
  
  let displayAmount: String
  let type: TransactionPaymentTypeModel
  
  private enum CodingKeys: String, CodingKey {
    case displayAmount = "display_amount"
    case type = "provider"
  }
  
}

enum TransactionPaymentTypeModel: String, Decodable, CustomStringConvertible {
  
  case wallet
  case rebilly
  case paypal
  
  var isWallet: Bool { return self == .wallet }
  
  var description: String {
    switch self {
    case .wallet: return L.tiliaWallet
    case .rebilly: return L.creditCard
    case .paypal: return L.paypal
    }
  }
  
}
