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
  let reference: TransactionReferenceModel?
  let createDate: Date
  let total: String
  let subTotal: TransactionSubTotalModel?
  let items: [LineItemModel]
  let paymentMethods: [TransactionPaymentMethodModel]
  
  private enum RootCodingKeys: String, CodingKey {
    case id = "transaction_id"
    case type = "transaction_type"
    case role = "transaction_role"
    case status = "transaction_status"
    case accountId = "account_id"
    case transaction = "transaction_data"
  }
  
  private enum TransactionCodingKeys: String, CodingKey {
    case referenceType = "reference_type"
    case referenceId = "reference_id"
    case createDate = "created"
    case items = "line_items"
    case paymentMethods = "payment_methods"
    case summary
  }
  
  private enum SummaryCodingKeys: String, CodingKey {
    case displayAmount = "display_amount"
    case subTotal = "subtotal"
    case tax
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: RootCodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    type = try container.decode(TransactionType.self, forKey: .type)
    role = try container.decode(TransactionRole.self, forKey: .role)
    status = try container.decode(TransactionStatus.self, forKey: .status)
    accountId = try container.decode(String.self, forKey: .accountId)
    
    let transactionContainer = try container.nestedContainer(keyedBy: TransactionCodingKeys.self, forKey: .transaction)
    
    if let referenceId = try transactionContainer.decodeIfPresent(String.self, forKey: .referenceId),
       let referenceType = try transactionContainer.decodeIfPresent(String.self, forKey: .referenceType) {
      self.reference = .init(id: referenceId, type: referenceType)
    } else {
      self.reference = nil
    }
    
    let items = try transactionContainer.decode([String: LineItemModel].self, forKey: .items)
    self.items = items.values.sorted { $0.sortOrder ?? 0 < $1.sortOrder ?? 0 }
    
    let paymentMethods = try transactionContainer.decode([String: TransactionPaymentMethodModel].self, forKey: .paymentMethods)
    self.paymentMethods = paymentMethods.values.sorted { $0.type.isWallet && !$1.type.isWallet }
    
    let createDateString = try transactionContainer.decode(String.self, forKey: .createDate)
    if let createDate = ISO8601DateFormatter().date(from: createDateString) {
      self.createDate = createDate
    } else {
      throw TLError.invalidDateFormatForString(createDateString)
    }
    
    if transactionContainer.contains(.summary) {
      let summaryContainer = try transactionContainer.nestedContainer(keyedBy: SummaryCodingKeys.self, forKey: .summary)
      total = try summaryContainer.decode(String.self, forKey: .displayAmount)
      
      let subTotalContainer = try summaryContainer.nestedContainer(keyedBy: SummaryCodingKeys.self, forKey: .subTotal)
      let taxContainer = try summaryContainer.nestedContainer(keyedBy: SummaryCodingKeys.self, forKey: .tax)
      if let subTotal = (try subTotalContainer.decodeIfPresent(String.self, forKey: .displayAmount))?.toNilIfEmpty(),
         let tax = (try taxContainer.decodeIfPresent(String.self, forKey: .displayAmount))?.toNilIfEmpty() {
        self.subTotal = .init(total: subTotal, tax: tax)
      } else {
        self.subTotal = nil
      }
    } else {
      // TODO: - Fix me
      total = ""
      subTotal = nil
    }
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

struct TransactionSubTotalModel {
  
  let total: String
  let tax: String
  
}

struct TransactionReferenceModel {
  
  let id: String
  let type: String
  
}
