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
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    type = try container.decode(TransactionType.self, forKey: .type)
    role = try container.decode(TransactionRole.self, forKey: .role)
    status = try container.decode(TransactionStatus.self, forKey: .status)
    accountId = try container.decode(String.self, forKey: .accountId)
    items = [] // Fix me
    
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
