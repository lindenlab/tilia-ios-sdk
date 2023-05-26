//
//  PaymentSelectionSectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 24.05.2023.
//

import UIKit

struct PaymentSelectionSectionBuilder {
  
  typealias CellDelegate = PaymentMethodSwitchCellDelegate & PaymentMethodRadioCellDelegate
  typealias FooterDelegate = PaymentFooterViewDelegate & TextViewWithLinkDelegate
  
  struct Section {
    
    struct Item {
      let title: String
      let subTitle: String?
      let isSwitch: Bool
      var isSelected: Bool
      var isEnabled: Bool
      let icon: UIImage?
      let isDividerHidden: Bool
      let areSwipeActionsEnabled: Bool
    }
    
    var items: [Item]
    var isPayButtonEnabled: Bool
    var isEmpty: Bool { return items.isEmpty }
  }
  
  func numberOfRows(in section: Section) -> Int {
    return section.items.count
  }
  
  func cell(for section: Section,
            in tableView: UITableView,
            at indexPath: IndexPath,
            delegate: CellDelegate) -> UITableViewCell {
    let cell: UITableViewCell
    let item = section.items[indexPath.row]
    if item.isSwitch {
      let newCell = tableView.dequeue(PaymentMethodSwitchCell.self, for: indexPath)
      newCell.configure(image: item.icon,
                        title: item.title,
                        delegate: delegate)
      newCell.configure(isOn: item.isSelected)
      newCell.configure(isEnabled: item.isEnabled)
      cell = newCell
    } else {
      let newCell = tableView.dequeue(PaymentMethodRadioCell.self, for: indexPath)
      newCell.configure(title: item.title,
                        subTitle: item.subTitle,
                        isDividerHidden: item.isDividerHidden,
                        icon: item.icon,
                        delegate: delegate)
      newCell.configure(isSelected: item.isSelected)
      newCell.configure(isEnabled: item.isEnabled)
      cell = newCell
    }
    return cell
  }
  
  func header(for section: Section,
              in tableView: UITableView) -> UIView {
    let view = tableView.dequeue(TitleInfoHeaderFooterView.self)
    view.configure(title: L.choosePaymentMethod, subTitle: nil)
    return view
  }
  
  func footer(for section: Section,
              in tableView: UITableView,
              delegate: FooterDelegate) -> UIView {
    let view = tableView.dequeue(PaymentFooterView.self)
    let title = section.isEmpty ? nil : L.usePaymentMethod
    view.configure(payButtonTitle: title,
                   closeButtonTitle: L.cancel,
                   isCreditCardButtonHidden: false,
                   delegate: delegate,
                   textViewSubTitle: title,
                   textViewDelegate: delegate)
    view.configure(isPayButtonEnabled: section.isPayButtonEnabled)
    return view
  }
  
  func swipeActionsConfiguration(for section: Section,
                                 at index: Int,
                                 withDeleteAction deleteAction: @escaping () -> Void,
                                 andRenameAction renameAction: @escaping () -> Void) -> UISwipeActionsConfiguration? {
    guard section.items[index].areSwipeActionsEnabled else { return nil }
    let deleteAction = UIContextualAction(style: .destructive,
                                          title: L.remove) { _, _, handler in
      deleteAction()
      handler(true)
    }
    let renameAction = UIContextualAction(style: .normal,
                                          title: L.rename) { _, _, handler in
      renameAction()
      handler(true)
    }
    return UISwipeActionsConfiguration(actions: [deleteAction, renameAction])
  }
  
  func sections(for model: PaymentSelectionContent) -> [Section] {
    let amount = model.amount
    let walletBalance = model.walletBalance
    let paymentMethods = model.paymentMethods
    let hasNotOnlyWallet = paymentMethods.first(where: { !$0.type.isWallet }) != nil
    let items: [Section.Item] = paymentMethods.enumerated().map { index, value in
      let isSwitch = value.type.isWallet && hasNotOnlyWallet && !amount.isEmpty
      let title: String = {
        if isSwitch, let balance = walletBalance {
          return L.useYourBalance(with: balance.display)
        } else {
          return value.display
        }
      }()
      let isEnabled: Bool = {
        if value.type.isWallet, let balance = walletBalance?.balance, let amount = amount {
          return balance >= amount || hasNotOnlyWallet
        } else {
          return true
        }
      }()
      return .init(title: title,
                   subTitle: !isSwitch && value.type.isWallet ? walletBalance?.display : nil,
                   isSwitch: isSwitch,
                   isSelected: false,
                   isEnabled: isEnabled,
                   icon: value.type.icon,
                   isDividerHidden: index == paymentMethods.count - 1,
                   areSwipeActionsEnabled: !value.type.isWallet)
    }
    return [.init(items: items,
                  isPayButtonEnabled: false)]
  }
  
  
  func updateSections(_ sections: inout [Section],
                      in tableView: UITableView,
                      isPayButtonEnabled: Bool) {
    sections[0].isPayButtonEnabled = isPayButtonEnabled
    if let footer = tableView.footerView(forSection: 0) as? PaymentFooterView {
      footer.configure(isPayButtonEnabled: isPayButtonEnabled)
    }
  }
  
  func updateSections(_ sections: inout [Section],
                      in tableView: UITableView,
                      at index: Int,
                      isSelected: Bool) {
    sections[0].items[index].isSelected = isSelected
    let indexPath = IndexPath(row: index, section: 0)
    if let cell = tableView.cellForRow(at: indexPath) as? PaymentMethodRadioCell, !isSelected {
      cell.configure(isSelected: isSelected)
    }
  }
  
  func updateSections(_ sections: inout [Section],
                      in tableView: UITableView,
                      isEnabled: Bool) {
    for (index, value) in sections[0].items.enumerated() where !value.isSwitch {
      sections[0].items[index].isEnabled = isEnabled
      let indexPath = IndexPath(row: index, section: 0)
      if let cell = tableView.cellForRow(at: indexPath) as? PaymentMethodRadioCell {
        cell.configure(isEnabled: isEnabled)
      }
    }
  }
  
}
