//
//  TransactionDetailsModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 25.08.2022.
//

import Foundation

struct TransactionDetailsModel: Decodable {
  
  let id: String
  let type: TransactionTypeModel
  let status: TransactionStatusModel
  let description: String
  let accountId: String
  let referenceType: String?
  let referenceId: String?
  let transactionDate: Date
  let createdDate: Date?
  let total: TransactionTotalModel
  let lineItems: [LineItemModel]?
  let recipientItems: [TransactionRecipientItemModel]?
  let refundLineItems: [RefundItemModel]?
  let paymentMethods: [TransactionPaymentMethodModel]?
  let refundPaymentMethods: [RefundItemModel]?
  let destinationPaymentMethod: String?
  let sourcePaymentMethod: String?
  let isPoboSourcePaymentMethodProvider: Bool
  let userReceivedAmount: String?
  
  private enum RootCodingKeys: String, CodingKey {
    case id = "transaction_id"
    case type = "transaction_type"
    case status = "transaction_status"
    case accountId = "account_id"
    case data = "transaction_data"
    case transactionDate = "transaction_date"
    case description = "transaction_description"
  }
  
  private enum TransactionCodingKeys: String, CodingKey {
    case referenceType = "reference_type"
    case referenceId = "reference_id"
    case lineItems = "line_items"
    case recipientItems = "recipient_items"
    case refundLineItems = "refund_line_items"
    case paymentMethods = "payment_methods"
    case refundPaymentMethods = "refund_payment_methods"
    case destinationPaymentMethod = "destination_payment_method_display_string"
    case sourcePaymentMethod = "source_payment_method_display_string"
    case sourcePaymentMethodProvider = "source_payment_method_provider"
    case userReceivedAmount = "user_received_amount_display"
    case payout
  }
  
  private enum PayoutCodingKeys: String, CodingKey {
    case createdDate = "created"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: RootCodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    type = try container.decode(TransactionTypeModel.self, forKey: .type)
    status = try container.decode(TransactionStatusModel.self, forKey: .status)
    description = try container.decode(String.self, forKey: .description)
    accountId = try container.decode(String.self, forKey: .accountId)
    transactionDate = try Self.date(for: container, with: .transactionDate)
    total = try TransactionTotalModel(from: decoder)
    
    let transactionContainer = try container.nestedContainer(keyedBy: TransactionCodingKeys.self, forKey: .data)
    
    referenceType = try transactionContainer.decodeIfPresent(String.self, forKey: .referenceType)
    referenceId = try transactionContainer.decodeIfPresent(String.self, forKey: .referenceId)
    
    let lineItems = try transactionContainer.decodeIfPresent([String: LineItemModel].self, forKey: .lineItems)
    self.lineItems = lineItems?.values.sorted { $0.sortOrder ?? 0 < $1.sortOrder ?? 0 }
    recipientItems = try transactionContainer.decodeIfPresent([TransactionRecipientItemModel].self, forKey: .recipientItems)
    refundLineItems = try transactionContainer.decodeIfPresent([RefundItemModel].self, forKey: .refundLineItems)
    
    let paymentMethods = try transactionContainer.decodeIfPresent([String: TransactionPaymentMethodModel].self, forKey: .paymentMethods)
    self.paymentMethods = paymentMethods?.values.sorted { $0.type.isWallet && !$1.type.isWallet }
    refundPaymentMethods = try transactionContainer.decodeIfPresent([RefundItemModel].self, forKey: .refundPaymentMethods)
    destinationPaymentMethod = try transactionContainer.decodeIfPresent(String.self, forKey: .destinationPaymentMethod)
    userReceivedAmount = try transactionContainer.decodeIfPresent(String.self, forKey: .userReceivedAmount)
    // Parse only for tokenPurchase and tokenConvert
    switch self.type {
    case .tokenPurchase, .tokenConvert:
      sourcePaymentMethod = try transactionContainer.decode(String.self, forKey: .sourcePaymentMethod)
    default:
      sourcePaymentMethod = nil
    }
    isPoboSourcePaymentMethodProvider = try transactionContainer.decodeIfPresent(String.self, forKey: .sourcePaymentMethodProvider) == "pobo"
    
    // Parse only for payout
    if transactionContainer.contains(.payout) {
      let payoutContainer = try transactionContainer.nestedContainer(keyedBy: PayoutCodingKeys.self, forKey: .payout)
      createdDate = try Self.date(for: payoutContainer, with: .createdDate)
    } else {
      createdDate = nil
    }
  }
  
}

enum TransactionTypeModel: String, Decodable {
  
  case userPurchase = "user_purchase"
  case userPurchaseEscrow = "user_purchase_escrow"
  case userPurchaseRecipient = "user_purchase_recipient"
  case payout
  case tokenPurchase = "token_purchase"
  case tokenConvert = "token_convert"
  case refund
  
}

enum TransactionStatusModel: String, Decodable, CustomStringConvertible {
  
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

struct TransactionRecipientItemModel: Decodable {
  
  let description: String
  let displayAmount: String
  let paymentMethodDescription: String
  let paymentMethodDisplayAmount: String
  
  private enum CodingKeys: String, CodingKey {
    case description
    case displayAmount = "amount_received_display"
    case paymentMethodDescription = "payment_method_display_string"
    case paymentMethodDisplayAmount = "amount_received_less_fees_display"
  }
  
}

struct TransactionTotalModel: Decodable {
  
  let total: String
  let subTotal: String?
  let tax: String?
  let tiliaFee: String?
  let publisherFee: String?
  
  private enum CodingKeys: String, CodingKey {
    case transactionType = "transaction_type"
    case transactionData = "transaction_data"
  }
  
  private enum BuyerPurchaseCodingKeys: String, CodingKey {
    case summary
    case totalAmount = "total_amount"
    case displayAmount = "display_amount"
    case subTotal = "subtotal"
    case tax
  }
  
  private enum SellerPurchaseCodingKeys: String, CodingKey {
    case totalReceivedLessFeesDisplay = "total_received_less_fees_display"
    case totalReceivedDisplay = "total_received_display"
    case totalFeesPaidDisplay = "total_fees_paid_display"
    case totalFeesPaidAmount = "total_fees_paid"
  }
  
  private enum PayoutCodingKeys: String, CodingKey {
    case payoutLessFeesDisplay = "payout_amount_less_fee_display"
    case payoutTotalDisplay = "payout_total_display"
    case payoutFeesDisplay = "payout_fee_display"
    case payoutFeesAmount = "payout_fee"
  }
  
  private enum TokenCodingKeys: String, CodingKey {
    case subtotalAmountDisplay = "subtotal_amount_display"
    case taxAmount = "tax_amount"
    case taxAmountDisplay = "tax_amount_display"
    case totalAmountDisplay = "total_amount_display"
    case tiliaFeeAmount = "tilia_fee_amount"
    case tiliaFeeAmountDisplay = "tilia_fee_amount_display"
    case publisherFeeAmount = "publisher_fee_amount"
    case publisherFeeAmountDisplay = "publisher_fee_amount_display"
  }
  
  private enum RefundCodingKeys: String, CodingKey {
    case subtotalAmountDisplay = "subtotal_amount_display"
    case taxAmount = "tax_total_amount"
    case taxAmountDisplay = "tax_amount_display"
    case totalAmountDisplay = "total_amount_display"
  }
  
  init(from decoder: Decoder) throws {
    let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
    let type = try rootContainer.decode(TransactionTypeModel.self, forKey: .transactionType)
    
    switch type {
    case .userPurchase, .userPurchaseEscrow:
      let container = try rootContainer.nestedContainer(keyedBy: BuyerPurchaseCodingKeys.self, forKey: .transactionData)
      let summaryContainer = try container.nestedContainer(keyedBy: BuyerPurchaseCodingKeys.self, forKey: .summary)
      total = try summaryContainer.decode(String.self, forKey: .displayAmount)
      let subTotalContainer = try summaryContainer.nestedContainer(keyedBy: BuyerPurchaseCodingKeys.self, forKey: .subTotal)
      let subTotal = try subTotalContainer.decode(String.self, forKey: .displayAmount)
      self.subTotal = Self.subTotal(total: total, subTotal: subTotal)
      let taxContainer = try summaryContainer.nestedContainer(keyedBy: BuyerPurchaseCodingKeys.self, forKey: .tax)
      tax = try Self.displayAmount(for: taxContainer, doubleKey: .totalAmount, stringKey: .displayAmount)
      tiliaFee = nil
      publisherFee = nil
    case .userPurchaseRecipient:
      let container = try rootContainer.nestedContainer(keyedBy: SellerPurchaseCodingKeys.self, forKey: .transactionData)
      total = try container.decode(String.self, forKey: .totalReceivedLessFeesDisplay)
      let subTotal = try container.decode(String.self, forKey: .totalReceivedDisplay)
      self.subTotal = Self.subTotal(total: total, subTotal: subTotal)
      tax = try Self.displayAmount(for: container, doubleKey: .totalFeesPaidAmount, stringKey: .totalFeesPaidDisplay)
      tiliaFee = nil
      publisherFee = nil
    case .payout:
      let container = try rootContainer.nestedContainer(keyedBy: PayoutCodingKeys.self, forKey: .transactionData)
      total = try container.decode(String.self, forKey: .payoutLessFeesDisplay)
      let subTotal = try container.decode(String.self, forKey: .payoutTotalDisplay)
      self.subTotal = Self.subTotal(total: total, subTotal: subTotal)
      tax = try Self.displayAmount(for: container, doubleKey: .payoutFeesAmount, stringKey: .payoutFeesDisplay)
      tiliaFee = nil
      publisherFee = nil
    case .tokenPurchase, .tokenConvert:
      let container = try rootContainer.nestedContainer(keyedBy: TokenCodingKeys.self, forKey: .transactionData)
      total = try container.decode(String.self, forKey: .totalAmountDisplay)
      let subTotal = try container.decode(String.self, forKey: .subtotalAmountDisplay)
      self.subTotal = Self.subTotal(total: total, subTotal: subTotal)
      tax = try Self.displayAmount(for: container, doubleKey: .taxAmount, stringKey: .taxAmountDisplay)
      tiliaFee = try Self.displayAmount(for: container, doubleKey: .tiliaFeeAmount, stringKey: .tiliaFeeAmountDisplay)
      publisherFee = try Self.displayAmount(for: container, doubleKey: .publisherFeeAmount, stringKey: .publisherFeeAmountDisplay)
    case .refund:
      let container = try rootContainer.nestedContainer(keyedBy: RefundCodingKeys.self, forKey: .transactionData)
      total = try container.decode(String.self, forKey: .totalAmountDisplay)
      let subTotal = try container.decode(String.self, forKey: .subtotalAmountDisplay)
      self.subTotal = Self.subTotal(total: total, subTotal: subTotal)
      tax = try Self.displayAmount(for: container, doubleKey: .taxAmount, stringKey: .taxAmountDisplay)
      tiliaFee = nil
      publisherFee = nil
    }
  }
  
}

struct RefundItemModel: Decodable {
  
  let description: String
  let displayAmount: String
  
  private enum CodingKeys: String, CodingKey {
    case description
    case displayAmount = "amount_display"
  }
  
}

// MARK: - Private Methods

private extension TransactionDetailsModel {
  
  static func date<T: CodingKey>(for container: KeyedDecodingContainer<T>, with key: KeyedDecodingContainer<T>.Key) throws -> Date {
    let dateString = try container.decode(String.self, forKey: key)
    let formatter = ISO8601DateFormatter()
    // Try to parse without fractional seconds
    if let date = formatter.date(from: dateString) {
      return date
    } else {
      formatter.formatOptions.insert(.withFractionalSeconds)
      if let date = formatter.date(from: dateString) {
        return date
      } else {
        throw TLError.invalidDateFormatForString(dateString)
      }
    }
  }
  
}

private extension TransactionTotalModel {
  
  static func displayAmount<T: CodingKey>(for container: KeyedDecodingContainer<T>, doubleKey: KeyedDecodingContainer<T>.Key, stringKey: KeyedDecodingContainer<T>.Key) throws -> String? {
    let doubleValue = try container.decode(Double.self, forKey: doubleKey)
    return doubleValue.isEmpty ? nil : try container.decode(String.self, forKey: stringKey)
  }
  
  static func subTotal(total: String, subTotal: String) -> String? {
    return total != subTotal ? subTotal : nil
  }
  
}
