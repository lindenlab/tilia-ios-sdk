//
//  TransactionHistorySectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 15.09.2022.
//

import UIKit

struct TransactionHistorySectionBuilder {
  
  typealias TableUpdate = (insertSections: IndexSet?, insertRows: [IndexPath]?)
  
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
  
  func updateSections(with items: [TransactionDetailsModel], for sectionType: SectionType, oldLastItem: TransactionDetailsModel?, sections: inout [Section]) -> TableUpdate {
    switch sectionType {
    case .pending:
      return updatePendingSection(with: items,
                                  for: sectionType,
                                  sections: &sections)
    case .history:
      return updateHistorySections(with: items,
                                   for: sectionType,
                                   oldLastItem: oldLastItem,
                                   sections: &sections)
    }
  }
  
}

// MARK: - Private Methods

private extension TransactionHistorySectionBuilder {
  
  func updateHistorySections(with items: [TransactionDetailsModel], for sectionType: SectionType, oldLastItem: TransactionDetailsModel?, sections: inout [Section]) -> TableUpdate {
    let oldLastSectionIndex = sections.count - 1
    var lastItem = oldLastItem
    var insertRows: [IndexPath] = []
    items.enumerated().forEach { index, item in
      let isItemLast = self.isLast(in: items, index: index)
      if let lastItem = lastItem, lastItem.transactionDate.getDateDiff(for: item.transactionDate) == 0 {
        let lastSectionIndex = sections.count - 1
        let lastItemIndex = sections[lastSectionIndex].items.count - 1
        if lastSectionIndex == oldLastSectionIndex {
          insertRows.append(.init(row: lastItemIndex + 1,
                                  section: lastSectionIndex))
        }
        if lastItemIndex >= 0, sections[lastSectionIndex].items[lastItemIndex].isLast {
          sections[lastSectionIndex].items[lastItemIndex].isLast = false
        }
        sections[lastSectionIndex].items.append(self.item(for: item,
                                                          isLast: isItemLast,
                                                          sectionType: sectionType))
      } else {
        let title = item.transactionDate.string(formatter: .longDateFormatter)
        sections.append(.init(header: .init(title: title, value: nil),
                              items: [self.item(for: item,
                                                isLast: isItemLast,
                                                sectionType: sectionType)]))
      }
      if isItemLast {
        let count = String(sections[sections.count - 1].items.count)
        let value = L.total(with: count).attributedString(font: .systemFont(ofSize: 12),
                                                          color: .tertiaryTextColor,
                                                          subStrings: (count, .boldSystemFont(ofSize: 12), .tertiaryTextColor))
        sections[sections.count - 1].header?.value = value
      }
      lastItem = item
    }
    let insertSectionsRange = oldLastSectionIndex + 1..<sections.count
    let insertSections = insertSectionsRange.isEmpty ? nil : IndexSet(integersIn:insertSectionsRange)
    return (insertSections, insertRows.isEmpty ? nil : insertRows)
  }
  
  func updatePendingSection(with items: [TransactionDetailsModel], for sectionType: SectionType, sections: inout [Section]) -> TableUpdate {
    var insertRows: [IndexPath] = []
    if sections.isEmpty {
      let count = items.count
      let headerItems = items.enumerated().map { index, item in
        return self.item(for: item,
                         isLast: index == count - 1,
                         sectionType: sectionType)
      }
      sections.append(.init(header: nil, items: headerItems))
    } else {
      let lastItemIndex = sections[0].items.count - 1
      if lastItemIndex >= 0, sections[0].items[lastItemIndex].isLast {
        sections[0].items[lastItemIndex].isLast = false
      }
      insertRows.append(.init(row: lastItemIndex + 1, section: 0))
    }
    return (nil, insertRows.isEmpty ? nil : insertRows)
  }
  
  func item(for model: TransactionDetailsModel, isLast: Bool, sectionType: SectionType) -> Section.Item {
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
