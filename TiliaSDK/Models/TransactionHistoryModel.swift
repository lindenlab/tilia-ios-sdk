//
//  TransactionHistoryModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 29.09.2022.
//

import Foundation

struct TransactionHistoryModel: Decodable {
  
  let total: Int
  let transactions: [TransactionDetailsModel]
  
  private enum CodingKeys: String, CodingKey {
    case total
    case transactions
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.total = try container.decode(Int.self, forKey: .total)
    let failableModel = try container.decode(FailableDecodableArrayModel<TransactionDetailsModel>.self, forKey: .transactions)
    self.transactions = failableModel.items
  }
  
}
