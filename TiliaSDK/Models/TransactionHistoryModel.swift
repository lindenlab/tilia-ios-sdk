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
  
}
