//
//  TransactionHistorySectionModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 04.10.2022.
//

import UIKit

struct TransactionHistorySectionModel {
  
  enum SectionType: Int, CaseIterable {
    case pending
    case history
    
    var description: String {
      switch self {
      case .pending: return L.pending
      case .history: return L.history
      }
    }
  }
  
  struct Header {
    let title: String
    var value: NSAttributedString?
  }
  
  struct Item {
    let title: String
    let subTitle: String
    let value: NSAttributedString
    let subValueImage: UIImage?
    let subValueTitle: String?
    var isLast: Bool
  }
  
  var header: Header?
  var items: [Item]
  
}
