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
  let transactionDate: Date
  let total: String
  let subTotal: String?
  let tax: String?
  let lineItems: [LineItemModel]?
  let recipientItems: [RecipientItemModel]?
  let paymentMethods: [TransactionPaymentMethodModel]?
  
  private enum RootCodingKeys: String, CodingKey {
    case id = "transaction_id"
    case type = "transaction_type"
    case role = "transaction_role"
    case status = "transaction_status"
    case accountId = "account_id"
    case data = "transaction_data"
    case transactionDate = "transaction_date"
  }
  
  private enum TransactionCodingKeys: String, CodingKey {
    case referenceType = "reference_type"
    case referenceId = "reference_id"
    case lineItems = "line_items"
    case recipientItems = "recipient_items"
    case paymentMethods = "payment_methods"
    case summary
    case totalReceivedLessFeesDisplay = "total_received_less_fees_display"
    case totalReceivedDisplay = "total_received_display"
    case totalReceivedAmount = "total_received"
    case totalFeesPaidDisplay = "total_fees_paid_display"
    case totalFeesPaidAmount = "total_fees_paid"
  }
  
  private enum SummaryCodingKeys: String, CodingKey {
    case totalAmount = "total_amount"
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
    
    let transactionDateString = try container.decode(String.self, forKey: .transactionDate)
    if let transactionDate = DateFormatter.customDateAndTimeWithTimeZoneFormatter.date(from: transactionDateString) {
      self.transactionDate = transactionDate
    } else {
      throw TLError.invalidDateFormatForString(transactionDateString)
    }
    
    let transactionContainer = try container.nestedContainer(keyedBy: TransactionCodingKeys.self, forKey: .data)
    referenceType = try transactionContainer.decodeIfPresent(String.self, forKey: .referenceType)
    referenceId = try transactionContainer.decodeIfPresent(String.self, forKey: .referenceId)
    
    let lineItems = try transactionContainer.decodeIfPresent([String: LineItemModel].self, forKey: .lineItems)
    self.lineItems = lineItems?.values.sorted { $0.sortOrder ?? 0 < $1.sortOrder ?? 0 }
    
    let recipientItems = try transactionContainer.decodeIfPresent([RecipientItemModel].self, forKey: .recipientItems)
    self.recipientItems = recipientItems
    
    let paymentMethods = try transactionContainer.decodeIfPresent([String: TransactionPaymentMethodModel].self, forKey: .paymentMethods)
    self.paymentMethods = paymentMethods?.values.sorted { $0.type.isWallet && !$1.type.isWallet }
    
    if transactionContainer.contains(.summary) {
      let summaryContainer = try transactionContainer.nestedContainer(keyedBy: SummaryCodingKeys.self, forKey: .summary)
      total = try summaryContainer.decode(String.self, forKey: .displayAmount)
      
      let subTotalContainer = try summaryContainer.nestedContainer(keyedBy: SummaryCodingKeys.self, forKey: .subTotal)
      subTotal = try Self.displayAmount(for: subTotalContainer, doubleKey: .totalAmount, stringKey: .displayAmount)
      
      let taxContainer = try summaryContainer.nestedContainer(keyedBy: SummaryCodingKeys.self, forKey: .tax)
      tax = try Self.displayAmount(for: taxContainer, doubleKey: .totalAmount, stringKey: .displayAmount)
    } else {
      total = try transactionContainer.decode(String.self, forKey: .totalReceivedLessFeesDisplay)
      subTotal = try Self.displayAmount(for: transactionContainer, doubleKey: .totalReceivedAmount, stringKey: .totalReceivedDisplay)
      tax = try Self.displayAmount(for: transactionContainer, doubleKey: .totalFeesPaidAmount, stringKey: .totalFeesPaidDisplay)
    }
  }
  
  private static func displayAmount<T: CodingKey>(for container: KeyedDecodingContainer<T>, doubleKey: KeyedDecodingContainer<T>.Key, stringKey: KeyedDecodingContainer<T>.Key) throws -> String? {
    let doubleValue = try container.decode(Double.self, forKey: doubleKey)
    return doubleValue.isEmpty ? nil : try container.decode(String.self, forKey: stringKey)
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
