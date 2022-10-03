//
//  TransactionHistorySectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 15.09.2022.
//

import UIKit

struct TransactionHistorySectionBuilder {
  
  typealias TableUpdate = (insertSections: IndexSet, insertRows: [IndexPath])
  
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
      var value: String?
    }
    
    struct Item {
      let title: String
      let subTitle: String
      let value: NSAttributedString
      let subValueImage: UIImage?
      let subValueTitle: String?
      let isLast: Bool
    }
    
    var header: Header?
    var items: [Item]
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
                   isLast: item.isLast)
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
  
  func updateHistorySections(with items: [TransactionDetailsModel], oldLastItem: TransactionDetailsModel?, sections: inout [Section]) -> TableUpdate {
    let oldLastSectionIndex = sections.count - 1
    var lastItem = oldLastItem
    var insertRows: [IndexPath] = []
    items.enumerated().forEach { index, item in
      let isItemLast = self.isLast(in: items, index: index)
      if let lastItem = lastItem, lastItem.transactionDate.getDateDiff(for: item.transactionDate) == 0 {
        let lastSectionIndex = sections.count - 1
        if lastSectionIndex == oldLastSectionIndex {
          insertRows.append(.init(row: sections[lastSectionIndex].items.count, section: lastSectionIndex))
        }
        sections[lastSectionIndex].items.append(self.item(for: item, isLast: isItemLast))
      } else {
        let title = item.transactionDate.string(formatter: .longDateFormatter)
        sections.append(.init(header: .init(title: title, value: nil),
                              items: [self.item(for: item, isLast: isItemLast)]))
      }
      if isItemLast {
        let count = sections[sections.count - 1].items.count
        sections[sections.count - 1].header?.value = L.total(with: String(count))
      }
      lastItem = item
    }
    return (.init(integersIn: oldLastSectionIndex + 1..<sections.count), insertRows)
  }
  
}

// MARK: - Private Methods

private extension TransactionHistorySectionBuilder {
  
  func item(for model: TransactionDetailsModel, isLast: Bool) -> Section.Item {
    return .init(title: "Title for transaction",
                 subTitle: "SubTitle for transaction",
                 value: model.attributedValue,
                 subValueImage: model.status.subValueImage,
                 subValueTitle: model.status.subValueTitle,
                 isLast: isLast)
  }
  
  func isLast(in items: [TransactionDetailsModel], index: Int) -> Bool {
    if let nextItem = items[safe: index + 1], items[index].transactionDate.getDateDiff(for: nextItem.transactionDate) != 0 {
      return true
    } else if index == items.count - 1 {
      return true
    } else {
      return false
    }
  }
  
}

private extension TransactionDetailsModel {
  
  var attributedValue: NSAttributedString {
    var attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14, weight: .medium)]
    if status == .failed {
      attributes[.foregroundColor] = UIColor.primaryTextColor
      attributes[.strikethroughStyle] = NSUnderlineStyle.single
    } else {
      switch type {
      case .userPurchase:
        attributes[.foregroundColor] = UIColor.failureBackgroundColor
      default:
        attributes[.foregroundColor] = UIColor.successBackgroundColor
      }
    }
    return NSAttributedString(string: total.total, attributes: attributes)
  }
  
}

private extension TransactionStatusModel {
  
  var subValueImage: UIImage? {
    return self == .failed ? .failureIcon : nil
  }
  
  var subValueTitle: String? {
    return self == .failed ? self.description : nil
  }
  
}
