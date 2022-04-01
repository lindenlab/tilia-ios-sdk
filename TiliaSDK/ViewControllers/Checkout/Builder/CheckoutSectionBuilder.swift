//
//  CheckoutSectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 01.04.2022.
//

import UIKit

struct CheckoutSectionBuilder {
  
  enum Section {
    case summary(InvoiceModel)
    case payment(BalanceModel)
    case successfulPayment
    
    var numberOfRows: Int {
      switch self {
      case .summary(let model): return model.items.count
      default: return 1
      }
    }
    
    func cell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
      switch self {
      case let .summary(invoiceModel):
        let item = invoiceModel.items[indexPath.row]
        let cell = tableView.dequeue(CheckoutPayloadCell.self, for: indexPath)
        let lastItemIndex = tableView.numberOfRows(inSection: indexPath.section) - 1
        cell.configure(description: item.description,
                       product: item.productSku,
                       amount: item.displayAmount,
                       isDividerHidden: lastItemIndex == indexPath.row)
        return cell
      case let .payment(balanceModel):
        let cell = tableView.dequeue(CheckoutPaymentMethodCell.self, for: indexPath)
        cell.configure(title: L.walletBalance,
                       subTitle: balanceModel.display,
                       isSelected: true)
        return cell
      case .successfulPayment:
        return UITableViewCell()
      }
    }
    
    func header(for tableView: UITableView, in section: Int) -> UIView? {
      switch self {
      case let .summary(invoiceModel):
        let view = tableView.dequeue(ChekoutTitleHeaderView.self)
        view.configure(title: L.transactionSummary,
                       subTitle: "\(invoiceModel.referenceType) \(invoiceModel.referenceId)")
        return view
      case .payment:
        let view = tableView.dequeue(ChekoutTitleHeaderView.self)
        view.configure(title: L.choosePaymentMethod, subTitle: nil)
        return view
      case .successfulPayment:
        return nil
      }
    }
    
    func footer(for tableView: UITableView,
                in section: Int,
                delegate: CheckoutPaymentFooterViewDelegate?,
                textViewDelegate: TextViewWithLinkDelegate?) -> UIView {
      switch self {
      case let .summary(invoiceModel):
        let view = tableView.dequeue(CheckoutPayloadSummaryFooterView.self)
        view.configure(amount: invoiceModel.displayAmount)
        return view
      case .payment:
        let view = tableView.dequeue(CheckoutPaymentFooterView.self)
        view.configure(roundedButtonTitle: L.cancel,
                       delegate: delegate,
                       textViewDelegate: textViewDelegate)
        return view
      case .successfulPayment:
        let view = tableView.dequeue(CheckoutPaymentFooterView.self)
        view.configure(roundedButtonTitle: L.done,
                       delegate: delegate,
                       textViewDelegate: nil)
        return view
      }
    }
    
  }
  
  func summarySection(for invoice: InvoiceModel) -> Section {
    return .summary(invoice)
  }
  
  func paymentSection(for balance: BalanceModel) -> Section {
    return .payment(balance)
  }
  
  func successfulPaymentSection() -> Section {
    return .successfulPayment
  }
  
}
