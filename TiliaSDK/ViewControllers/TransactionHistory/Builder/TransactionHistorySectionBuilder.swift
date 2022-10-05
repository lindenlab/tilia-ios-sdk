//
//  TransactionHistorySectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 15.09.2022.
//

import UIKit

protocol TransactionHistorySectionBuilder {
  typealias TableUpdate = (insertSections: IndexSet?, insertRows: [IndexPath]?)
  
  func updateSections(with items: [TransactionDetailsModel], oldLastItem: TransactionDetailsModel?, sections: inout [TransactionHistorySectionModel]) -> TableUpdate
}

extension TransactionHistorySectionBuilder {
  
  func numberOfRows(in section: TransactionHistorySectionModel) -> Int {
    return section.items.count
  }
  
  func heightForHeader(in section: TransactionHistorySectionModel) -> CGFloat {
    return section.header == nil ? .leastNormalMagnitude : UITableView.automaticDimension
  }
  
  func cell(for section: TransactionHistorySectionModel,
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
  
  func header(for section: TransactionHistorySectionModel,
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

struct TransactionHistoryPendingSectionBuilder: TransactionHistorySectionBuilder {
  
  func updateSections(with items: [TransactionDetailsModel], oldLastItem: TransactionDetailsModel?, sections: inout [TransactionHistorySectionModel]) -> TableUpdate {
    guard !items.isEmpty else { return (nil, nil) }
    var insertRows: [IndexPath] = []
    if oldLastItem == nil {
      sections.append(.init(header: nil, items: []))
    }
    let lastItemIndex = sections[0].items.count - 1
    if lastItemIndex >= 0 {
      sections[0].items[lastItemIndex].isLast = false
    }
    let count = items.count
    items.enumerated().forEach { index, item in
      insertRows.append(.init(row: lastItemIndex + index + 1, section: 0))
      sections[0].items.append(self.item(for: item,
                                         isLast: index == count - 1,
                                         sectionType: .pending))
    }
    return (nil, insertRows.isEmpty ? nil : insertRows)
  }
  
}


struct TransactionHistoryHistorySectionBuilder: TransactionHistorySectionBuilder {
  
  func updateSections(with items: [TransactionDetailsModel], oldLastItem: TransactionDetailsModel?, sections: inout [TransactionHistorySectionModel]) -> TableUpdate {
    guard !items.isEmpty else { return (nil, nil) }
    let oldLastSectionIndex = sections.count - 1
    var lastSectionIndex = oldLastSectionIndex
    var lastItemIndex = -1
    if lastSectionIndex >= 0 && sections[lastSectionIndex].items.count - 1 >= 0 {
      lastItemIndex = sections[lastSectionIndex].items.count - 1
      sections[lastSectionIndex].items[lastItemIndex].isLast = false
    }
    var lastItem = oldLastItem
    var insertRows: [IndexPath] = []
    items.enumerated().forEach { index, item in
      let isItemLast = self.isLast(in: items, index: index)
      if let lastItem = lastItem, lastItem.transactionDate.getDateDiff(for: item.transactionDate) == 0 {
        if lastSectionIndex == oldLastSectionIndex {
          insertRows.append(.init(row: lastItemIndex + index + 1,
                                  section: lastSectionIndex))
        }
        sections[lastSectionIndex].items.append(self.item(for: item,
                                                          isLast: isItemLast,
                                                          sectionType: .history))
      } else {
        lastSectionIndex += 1
        let title = item.transactionDate.string(formatter: .longDateFormatter)
        sections.append(.init(header: .init(title: title, value: nil),
                              items: [self.item(for: item,
                                                isLast: isItemLast,
                                                sectionType: .history)]))
      }
      if isItemLast {
        let count = String(sections[lastSectionIndex].items.count)
        let value = L.total(with: count).attributedString(font: .systemFont(ofSize: 12),
                                                          color: .tertiaryTextColor,
                                                          subStrings: (count, .boldSystemFont(ofSize: 12), .tertiaryTextColor))
        sections[lastSectionIndex].header?.value = value
      }
      lastItem = item
    }
    let insertSectionsRange = oldLastSectionIndex + 1...lastSectionIndex
    let insertSections = insertSectionsRange.isEmpty ? nil : IndexSet(integersIn: insertSectionsRange)
    return (insertSections, insertRows.isEmpty ? nil : insertRows)
  }
  
}

extension TransactionHistorySectionTypeModel {
  
  var builder: TransactionHistorySectionBuilder {
    switch self {
    case .pending: return TransactionHistoryPendingSectionBuilder()
    case .history: return TransactionHistoryHistorySectionBuilder()
    }
  }
  
}

// MARK: - Private Methods

private extension TransactionHistorySectionBuilder {
  
  func item(for model: TransactionDetailsModel, isLast: Bool, sectionType: TransactionHistorySectionTypeModel) -> TransactionHistorySectionModel.Item {
    let subTitle: String
    switch sectionType {
    case .pending:
      subTitle = model.transactionDate.string(formatter: .longDateFormatter)
    case .history:
      subTitle = model.type.description
    }
    return .init(title: "Title for transaction",
                 subTitle: subTitle,
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

private extension TransactionTypeModel {
  
  var description: String {
    switch self {
    case .userPurchase: return L.purchase
    case .userPurchaseRecipient: return L.sale
    case .payout: return L.payout
    case .tokenPurchase: return L.tokenPurchase
    case .tokenConvert: return L.tokenConvert
    }
  }
  
}
