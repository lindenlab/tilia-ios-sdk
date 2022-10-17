//
//  GetTransactionHistoryModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 17.10.2022.
//

import Foundation

struct GetTransactionHistoryModel: Encodable {
  
  let limit: Int
  let offset: Int
  let statuses: String
  
  init(limit: Int, offset: Int, sectionType: TransactionHistorySectionTypeModel) {
    self.limit = limit
    self.offset = offset
    self.statuses = sectionType.statuses
  }
  
}

// MARK: - Private Methods

private extension TransactionHistorySectionTypeModel {
  
  var statuses: String {
    switch self {
    case .pending: return "pending"
    case .history: return "processed,payout-failed"
    }
  }
  
}
