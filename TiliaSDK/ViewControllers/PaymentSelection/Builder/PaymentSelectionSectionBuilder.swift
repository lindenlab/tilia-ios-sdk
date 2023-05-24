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
      let isSwitch: Bool
      var isSelected: Bool
      var isEnabled: Bool
      let icon: UIImage?
      let isDividerHidden: Bool
    }
    
    var items: [Item]
    var isPayButtonEnabled: Bool
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
    view.configure(payButtonTitle: L.usePaymentMethod,
                   closeButtonTitle: L.cancel,
                   isCreditCardButtonHidden: false,
                   delegate: delegate,
                   textViewSubTitle: L.usePaymentMethod,
                   textViewDelegate: delegate)
    view.configure(isPayButtonEnabled: section.isPayButtonEnabled)
    return view
  }
  
  func sections(for model: PaymentSelectionContent) -> [Section] {
    let paymentMethods = model.paymentMethods
    let walletBalance = model.walletBalance
    let items: [Section.Item] = paymentMethods.enumerated().map { index, value in
      let title: String = {
        if value.type.isWallet, let balance = walletBalance {
          return L.useYourBalance(with: balance.display)
        } else {
          return value.display
        }
      }()
      return .init(title: title,
                   isSwitch: value.type.isWallet,
                   isSelected: false,
                   isEnabled: true,
                   icon: value.type.icon,
                   isDividerHidden: index == paymentMethods.count - 1)
    }
    return [.init(items: items,
                  isPayButtonEnabled: false)]
  }
  
}
