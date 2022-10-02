//
//  TransactionHistorySectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 15.09.2022.
//

import UIKit

struct TransactionHistorySectionBuilder {
  
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
  
  struct Section {
    
    struct Header {
      let title: String
      let value: NSAttributedString
    }
    
    struct Item {
      let title: String
      let subTitle: String
      let value: NSAttributedString
      let subValueImage: UIImage?
      let subValueTitle: String?
      let isDividerHidden: Bool
    }
    
    let header: Header?
    let items: [Item]
  }
  
  func numberOfRows(in section: Section) -> Int {
    return section.items.count
  }
  
  func cell(for section: Section,
            in tableView: UITableView,
            at indexPath: IndexPath) -> UITableViewCell {
    let item = section.items[indexPath.row]
    let cell = tableView.dequeue(TransactionHistoryCell.self, for: indexPath)
    cell.configure(title: item.title,
                   subTitle: item.subTitle,
                   value: item.value,
                   subValueImage: item.subValueImage,
                   subValueTitle: item.subValueTitle,
                   isDividerHidden: item.isDividerHidden)
    return cell
  }
  
  func header(for section: Section,
              in tableView: UITableView) -> UIView? {
    if let header = section.header {
      let view = tableView.dequeue(TransactionHistoryHeaderView.self)
      view.configure(title: header.title, value: header.value)
      return view
    } else {
      return nil
    }
  }
  
}
