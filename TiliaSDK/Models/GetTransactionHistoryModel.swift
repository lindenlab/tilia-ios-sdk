//
//  GetTransactionHistoryModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 17.10.2022.
//

import Foundation

struct GetTransactionHistoryModel: Encodable {
  
  private enum CodingKeys: String, CodingKey {
    case limit
    case offset
    case statuses
    case accountId = "account_id"
  }
  
  let limit: Int
  let offset: Int
  let statuses: String
  let accountId: String?
  
  init(limit: Int,
       offset: Int,
       sectionType: TransactionHistorySectionTypeModel,
       accountId: String?) {
    self.limit = limit
    self.offset = offset
    self.statuses = sectionType.statuses
    self.accountId = accountId
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(limit, forKey: .limit)
    try container.encode(offset, forKey: .offset)
    try container.encode(statuses, forKey: .statuses)
    try container.encodeIfPresent(accountId, forKey: .accountId)
  }
  
}

// MARK: - Private Methods

private extension TransactionHistorySectionTypeModel {
  
  var statuses: String {
    switch self {
    case .completed: return "processed,payout-failed"
    case .pending: return "pending"
    }
  }
  
}
