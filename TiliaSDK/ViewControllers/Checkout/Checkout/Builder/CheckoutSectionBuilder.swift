//
//  CheckoutSectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 01.04.2022.
//

import UIKit

struct CheckoutSectionBuilder {
  
  typealias CellDelegate = PaymentMethodSwitchCellDelegate & PaymentMethodRadioCellDelegate
  typealias FooterDelegate = PaymentFooterViewDelegate & TextViewWithLinkDelegate
  
  enum Section {
    
    struct Summary {
      
      struct Item {
        let description: String
        let product: String
        let amount: String
        let isDividerHidden: Bool
      }
      
      let referenceType: String
      let referenceId: String
      let amount: String
      let items: [Item]
    }
    
    struct Payment {
      
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
      let isCreditCardButtonHidden: Bool
      var isEmpty: Bool { return items.isEmpty }
    }
    
    case summary(Summary)
    case payment(Payment)
    case successfulPayment
  }
  
  func numberOfRows(in section: Section) -> Int {
    switch section {
    case let .summary(model): return model.items.count
    case let .payment(model): return model.items.count
    case .successfulPayment: return 1
    }
  }
  
  func heightForHeader(in section: Section) -> CGFloat {
    switch section {
    case .successfulPayment: return .leastNormalMagnitude
    case let .payment(model): return model.isEmpty ? 20 : UITableView.automaticDimension
    default: return UITableView.automaticDimension
    }
  }
  
  func cell(for section: Section,
            in tableView: UITableView,
            at indexPath: IndexPath,
            delegate: CellDelegate,
            isLoading: Bool) -> UITableViewCell {
    switch section {
    case let .summary(invoiceModel):
      let item = invoiceModel.items[indexPath.row]
      let cell = tableView.dequeue(CheckoutPayloadCell.self, for: indexPath)
      cell.configure(description: item.description,
                     product: item.product,
                     amount: item.amount,
                     isDividerHidden: item.isDividerHidden)
      return cell
    case let .payment(model):
      let item = model.items[indexPath.row]
      let cell: UITableViewCell
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
      cell.isUserInteractionEnabled = !isLoading
      return cell
    case .successfulPayment:
      let cell = tableView.dequeue(ToastViewCell.self, for: indexPath)
      cell.configure(isSuccess: true,
                     title: L.success,
                     message: L.paymentProcessed)
      return cell
    }
  }
  
  func header(for section: Section,
              in tableView: UITableView) -> UIView? {
    switch section {
    case .summary:
      let view = tableView.dequeue(TitleInfoHeaderFooterView.self)
      // TODO: - Temporary remove
//      view.configure(title: L.transactionSummary,
//                     subTitle: "\(invoiceModel.referenceType) \(invoiceModel.referenceId)",
//                     spacing: 4)
      view.configure(title: L.transactionSummary,
                     subTitle: nil,
                     spacing: 4)
      return view
    case let .payment(model) where !model.isEmpty:
      let view = tableView.dequeue(TitleInfoHeaderFooterView.self)
      view.configure(title: L.choosePaymentMethod, subTitle: nil)
      return view
    default:
      return nil
    }
  }
  
  func footer(for section: Section,
              in tableView: UITableView,
              delegate: FooterDelegate,
              isLoading: Bool) -> UIView {
    switch section {
    case let .summary(model):
      let view = tableView.dequeue(CheckoutPayloadSummaryFooterView.self)
      view.configure(amount: model.amount)
      view.configure(isLoading: isLoading)
      return view
    case let .payment(model):
      let view = tableView.dequeue(PaymentFooterView.self)
      let title = model.isEmpty ? nil : L.payNow
      view.configure(payButtonTitle: title,
                     closeButtonTitle: L.cancel,
                     isCreditCardButtonHidden: model.isCreditCardButtonHidden,
                     delegate: delegate,
                     textViewSubTitle: title,
                     textViewDelegate: delegate)
      view.configure(isPayButtonEnabled: model.isPayButtonEnabled)
      return view
    case .successfulPayment:
      let view = tableView.dequeue(PaymentFooterView.self)
      view.configure(payButtonTitle: nil,
                     closeButtonTitle: L.done,
                     isCreditCardButtonHidden: true,
                     delegate: delegate,
                     textViewSubTitle: nil,
                     textViewDelegate: delegate)
      return view
    }
  }
  
  func swipeActionsConfiguration(for section: Section,
                                 withDeleteAction deleteAction: @escaping () -> Void,
                                 andRenameAction renameAction: @escaping () -> Void) -> UISwipeActionsConfiguration? {
    switch section {
    case .payment:
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
    default:
      return nil
    }
  }
  
  func sections(with model: CheckoutContent) -> [Section] {
    return [
      .summary(summaryModel(for: model.invoiceInfo)),
      .payment(paymentModel(for: model))
    ]
  }
  
  func updateSections(_ sections: [Section],
                      in tableView: UITableView,
                      isLoading: Bool) {
    for (index, value) in sections.enumerated() {
      switch value {
      case .summary:
        if let footerView = tableView.footerView(forSection: index) as? CheckoutPayloadSummaryFooterView {
          footerView.configure(isLoading: isLoading)
        }
      case .payment:
        (0..<tableView.numberOfRows(inSection: index)).forEach {
          guard let cell = tableView.cellForRow(at: .init(row: $0, section: index)) else { return }
          cell.isUserInteractionEnabled = !isLoading
        }
      default: continue
      }
    }
  }
  
  func updateSummarySection(for sections: inout [Section],
                            model: InvoiceInfoModel) -> IndexSet {
    switch sections[0] {
    case .summary:
      sections[0] = .summary(summaryModel(for: model))
    default:
      break
    }
    return [0]
  }
  
  func updatePaymentSection(for sections: inout [Section],
                            model: CheckoutContent) -> IndexSet {
    switch sections[1] {
    case .payment:
      sections[1] = .payment(paymentModel(for: model))
    default:
      break
    }
    return [1]
  }
  
  func updatePaymentSection(for sections: inout [Section],
                            in tableView: UITableView,
                            at index: Int,
                            isSelected: Bool) {
    switch sections[1] {
    case var .payment(model):
      model.items[index].isSelected = isSelected
      let indexPath = IndexPath(row: index, section: 1)
      if let cell = tableView.cellForRow(at: indexPath) as? PaymentMethodRadioCell, !isSelected {
        cell.configure(isSelected: isSelected)
      }
      sections[1] = .payment(model)
    default:
      break
    }
  }
  
  func updatePaymentSection(for sections: inout [Section],
                            in tableView: UITableView,
                            isEnabled: Bool) {
    switch sections[1] {
    case var .payment(model):
      for (index, value) in model.items.enumerated() where !value.isSwitch {
        model.items[index].isEnabled = isEnabled
        let indexPath = IndexPath(row: index, section: 1)
        if let cell = tableView.cellForRow(at: indexPath) as? PaymentMethodRadioCell {
          cell.configure(isEnabled: isEnabled)
        }
      }
      sections[1] = .payment(model)
    default:
      break
    }
  }
  
  func updatePaymentSection(for sections: inout [Section],
                            in tableView: UITableView,
                            isPayButtonEnabled: Bool) {
    switch sections[1] {
    case var .payment(model):
      model.isPayButtonEnabled = isPayButtonEnabled
      if let footer = tableView.footerView(forSection: 1) as? PaymentFooterView {
        footer.configure(isPayButtonEnabled: isPayButtonEnabled)
      }
      sections[1] = .payment(model)
    default:
      break
    }
  }
  
  func updateSectionsWithSuccessfulPayment(_ sections: inout [Section]) -> IndexSet {
    sections[1] = .successfulPayment
    return [1]
  }
  
}

// MARK: - Private Methods

private extension CheckoutSectionBuilder {
  
  func summaryModel(for model: InvoiceInfoModel) -> Section.Summary {
    let count = model.items.count
    let items: [Section.Summary.Item] = model.items.enumerated().map { index, item in
      return .init(description: item.description,
                   product: item.productSku,
                   amount: item.displayAmount,
                   isDividerHidden: index == count - 1)
    }
    return .init(referenceType: model.referenceType,
                 referenceId: model.referenceId,
                 amount: model.displayAmount,
                 items: items)
  }
  
  func paymentModel(for model: CheckoutContent) -> Section.Payment {
    let invoiceInfo = model.invoiceInfo
    let walletBalance = model.walletBalance
    let paymentMethods = model.paymentMethods
    let payment: Section.Payment
    if model.isVirtual {
      let items: [Section.Payment.Item] = [
        .init(title: walletBalance.display,
              isSwitch: false,
              isSelected: true,
              isEnabled: false,
              icon: .walletIcon,
              isDividerHidden: true)
      ]
      payment = .init(items: items,
                      isPayButtonEnabled: true,
                      isCreditCardButtonHidden: true)
    } else {
      let count = paymentMethods.count
      let hasNotOnlyWallet = paymentMethods.first(where: { !$0.type.isWallet }) != nil
      let items: [Section.Payment.Item] = paymentMethods.enumerated().map { index, value in
        return .init(title: value.type.isWallet ? L.useYourBalance(with: walletBalance.display) : value.display,
                     isSwitch: value.type.isWallet && hasNotOnlyWallet,
                     isSelected: false,
                     isEnabled: value.type.isWallet ? walletBalance.balance >= invoiceInfo.amount || hasNotOnlyWallet : true,
                     icon: value.type.icon,
                     isDividerHidden: index == count - 1)
      }
      payment = .init(items: items,
                      isPayButtonEnabled: false,
                      isCreditCardButtonHidden: false)
    }
    return payment
  }
  
}
