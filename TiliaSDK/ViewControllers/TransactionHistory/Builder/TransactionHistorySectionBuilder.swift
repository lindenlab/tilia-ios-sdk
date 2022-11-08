//
//  TransactionHistorySectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 15.09.2022.
//

import UIKit

protocol TransactionHistorySectionBuilder {
  typealias TableUpdate = (insertSections: IndexSet?, insertRows: [IndexPath]?)
  
  func updateSections(_ sections: inout [TransactionHistorySectionModel], in tableView: UITableView, with items: [TransactionDetailsModel], oldLastItem: TransactionDetailsModel?) -> TableUpdate
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
                   subValueTitle: item.subValueTitle)
    cell.configure(isLast: item.isLast)
    return cell
  }
  
  func header(for section: TransactionHistorySectionModel,
              in tableView: UITableView) -> UIView? {
    if let header = section.header {
      let view = tableView.dequeue(TransactionHistoryHeaderView.self)
      view.configure(title: header.title)
      view.configure(value: header.value)
      return view
    } else {
      return nil
    }
  }
  
  func updateTable(_ tableView: UITableView, isEmpty: Bool) {
    if isEmpty {
      guard tableView.backgroundView == nil else { return }
      let label = UILabel()
      label.font = .systemFont(ofSize: 14)
      label.textColor = .primaryTextColor
      label.textAlignment = .center
      label.text = L.transactionHistoryIsEmpty
      tableView.backgroundView = label
    } else {
      tableView.backgroundView?.removeFromSuperview()
      tableView.backgroundView = nil
    }
  }
  
}

struct TransactionHistoryCompletedSectionBuilder: TransactionHistorySectionBuilder {
  
  func updateSections(_ sections: inout [TransactionHistorySectionModel], in tableView: UITableView, with items: [TransactionDetailsModel], oldLastItem: TransactionDetailsModel?) -> TableUpdate {
    guard !items.isEmpty else { return (nil, nil) }
    var oldLastIndexes = updateLastSection(with: &sections, in: tableView)
    var lastSectionIndex = oldLastIndexes.section
    var lastItem = oldLastItem
    var insertRows: [IndexPath] = []
    items.enumerated().forEach { index, item in
      let isItemLast = self.isLast(in: items, index: index)
      if let lastItem = lastItem, lastItem.transactionDate.getDateDiff(for: item.transactionDate) == 0 {
        if lastSectionIndex == oldLastIndexes.section {
          insertRows.append(.init(row: oldLastIndexes.item + index + 1,
                                  section: lastSectionIndex))
        }
        sections[lastSectionIndex].items.append(self.item(for: item,
                                                          isLast: isItemLast,
                                                          sectionType: .completed))
      } else {
        lastSectionIndex += 1
        let title = item.transactionDate.string(formatter: .longDateFormatter)
        sections.append(.init(header: .init(title: title, value: nil),
                              items: [self.item(for: item,
                                                isLast: isItemLast,
                                                sectionType: .completed)]))
      }
      if isItemLast {
        let count = String(sections[lastSectionIndex].items.count)
        let value = L.total(with: count).attributedString(font: .systemFont(ofSize: 12),
                                                          color: .tertiaryTextColor,
                                                          subStrings: (count, .boldSystemFont(ofSize: 12), .tertiaryTextColor))
        sections[lastSectionIndex].header?.value = value
        if lastSectionIndex == oldLastIndexes.section {
          updateTable(tableView,
                      at: lastSectionIndex,
                      total: value)
        }
      }
      lastItem = item
    }
    oldLastIndexes.section += 1
    let insertSections = oldLastIndexes.section <= lastSectionIndex ? IndexSet(integersIn: oldLastIndexes.section...lastSectionIndex) : nil
    return (insertSections, insertRows.isEmpty ? nil : insertRows)
  }
  
}

struct TransactionHistoryPendingSectionBuilder: TransactionHistorySectionBuilder {
  
  func updateSections(_ sections: inout [TransactionHistorySectionModel], in tableView: UITableView, with items: [TransactionDetailsModel], oldLastItem: TransactionDetailsModel?) -> TableUpdate {
    guard !items.isEmpty else { return (nil, nil) }
    var insertRows: [IndexPath] = []
    insertRows.reserveCapacity(items.count)
    if oldLastItem == nil {
      sections.append(.init(header: nil, items: []))
    }
    let lastItemIndex = updateLastSection(with: &sections, in: tableView).item
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

extension TransactionHistorySectionTypeModel {
  
  var builder: TransactionHistorySectionBuilder {
    switch self {
    case .completed: return TransactionHistoryCompletedSectionBuilder()
    case .pending: return TransactionHistoryPendingSectionBuilder()
    }
  }
  
}

// MARK: - Private Methods

private extension TransactionHistorySectionBuilder {
  
  typealias Indexes = (section: Int, item: Int)
  
  func item(for model: TransactionDetailsModel, isLast: Bool, sectionType: TransactionHistorySectionTypeModel) -> TransactionHistorySectionModel.Item {
    let subTitle: String
    switch sectionType {
    case .completed:
      subTitle = model.type.description
    case .pending:
      subTitle = model.transactionDate.string(formatter: .longDateFormatter)
    }
    return .init(title: model.description,
                 subTitle: subTitle,
                 value: model.attributedValue,
                 subValueImage: model.status.subValueImage,
                 subValueTitle: model.status.subValueTitle,
                 isLast: isLast)
  }
  
  func isLast(in items: [TransactionDetailsModel], index: Int) -> Bool {
    if let nextItem = items[safe: index + 1], items[index].transactionDate.getDateDiff(for: nextItem.transactionDate) != 0 {
      return true
    } else {
      return index == items.count - 1
    }
  }
  
  func updateLastSection(with sections: inout [TransactionHistorySectionModel], in tableView: UITableView) -> Indexes {
    let lastSectionIndex = sections.count - 1
    var lastItemIndex = -1
    if lastSectionIndex >= 0 && sections[lastSectionIndex].items.count - 1 >= 0 {
      lastItemIndex = sections[lastSectionIndex].items.count - 1
      sections[lastSectionIndex].items[lastItemIndex].isLast = false
      updateTable(tableView,
                  at: .init(row: lastItemIndex, section: lastSectionIndex),
                  isLast: false)
    }
    return (lastSectionIndex, lastItemIndex)
  }
  
  func updateTable(_ tableView: UITableView, at indexPath: IndexPath, isLast: Bool) {
    guard let cell = tableView.cellForRow(at: indexPath) as? TransactionHistoryCell else { return }
    cell.configure(isLast: isLast)
  }
  
  func updateTable(_ tableView: UITableView, at sectionIndex: Int, total: NSAttributedString) {
    guard let header = tableView.headerView(forSection: sectionIndex) as? TransactionHistoryHeaderView else { return }
    header.configure(value: total)
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
      case .tokenPurchase where !isPoboSourcePaymentMethodProvider, .userPurchaseRecipient:
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
    case .userPurchase, .userPurchaseEscrow: return L.purchase
    case .userPurchaseRecipient: return L.sale
    case .payout: return L.payout
    case .tokenPurchase: return L.tokenPurchase
    case .tokenConvert: return L.tokenConvert
    case .refund: return L.refund
    }
  }
  
}
