//
//  TransactionHistorySectionModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 04.10.2022.
//

import UIKit

struct TransactionHistorySectionModel {
  
  struct Header {
    let title: String?
    var value: NSAttributedString?
    
    init(title: String? = nil, value: NSAttributedString? = nil) {
      self.title = title
      self.value = value
    }
  }
  
  struct Item {
    let title: String
    let subTitle: String
    let value: NSAttributedString
    let subValueImage: UIImage?
    let subValueTitle: String?
    var isLast: Bool
  }
  
  var header: Header
  var items: [Item]
  
}

enum TransactionHistorySectionTypeModel: Int, CaseIterable, CustomStringConvertible {
  
  case completed
  case pending
  
  var description: String {
    switch self {
    case .completed: return L.completed
    case .pending: return L.pending
    }
  }
  
}
