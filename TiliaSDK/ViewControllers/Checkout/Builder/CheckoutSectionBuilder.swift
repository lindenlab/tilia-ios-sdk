//
//  CheckoutSectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 01.04.2022.
//

import UIKit

struct CheckoutSectionBuilder {
  
  struct Summary {
    
    struct Item {
      let description: String
      let product: String
      let amount: String
    }
    
    let referenceType: String
    let referenceId: String
    let amount: String
    let items: [Item]
    let isLoading: Bool
  }
  
  struct Payment {
    
    struct Item {
      let title: String
      let subTitle: String?
      let isSelected: Bool
      let canSelect: Bool
    }
    
    let items: [Item]
    let isPayButtonEnabled: Bool
  }
  
  enum Section {
    case summary(Summary)
    case payment(Payment)
    case successfulPayment
    
    var numberOfRows: Int {
      switch self {
      case let .summary(model): return model.items.count
      case let .payment(model): return model.items.count
      case .successfulPayment: return 1
      }
    }
    
    var heightForHeader: CGFloat {
      switch self {
      case .successfulPayment: return .leastNormalMagnitude
      default: return UITableView.automaticDimension
      }
    }
    
    func cell(for tableView: UITableView,
              at indexPath: IndexPath,
              delegate: CheckoutPaymentMethodCellDelegate?) -> UITableViewCell {
      switch self {
      case let .summary(invoiceModel):
        let item = invoiceModel.items[indexPath.row]
        let cell = tableView.dequeue(CheckoutPayloadCell.self, for: indexPath)
        let lastItemIndex = tableView.numberOfRows(inSection: indexPath.section) - 1
        cell.configure(description: item.description,
                       product: item.product,
                       amount: item.amount,
                       isDividerHidden: lastItemIndex == indexPath.row)
        return cell
      case let .payment(model):
        let item = model.items[indexPath.row]
        let cell = tableView.dequeue(CheckoutPaymentMethodCell.self, for: indexPath)
        cell.configure(title: item.title,
                       subTitle: item.subTitle,
                       isSelected: item.isSelected,
                       canSelect: item.canSelect,
                       delegate: delegate)
        return cell
      case .successfulPayment:
        return tableView.dequeue(CheckoutSuccessfulPaymentCell.self, for: indexPath)
      }
    }
    
    func header(for tableView: UITableView,
                in section: Int) -> UIView? {
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
      case let .summary(model):
        let view = tableView.dequeue(CheckoutPayloadSummaryFooterView.self)
        view.configure(amount: model.amount, isLoading: model.isLoading)
        return view
      case .payment:
        let view = tableView.dequeue(CheckoutPaymentFooterView.self)
        view.configure(nonPrimaryButtonTitle: L.cancel,
                       delegate: delegate,
                       textViewDelegate: textViewDelegate)
        return view
      case .successfulPayment:
        let view = tableView.dequeue(CheckoutPaymentFooterView.self)
        view.configure(nonPrimaryButtonTitle: L.done,
                       delegate: delegate,
                       textViewDelegate: nil)
        return view
      }
    }
    
  }
  
  func successfulPaymentSection() -> Section {
    return .successfulPayment
  }
  
  func sections(with model: CheckoutContent) -> [Section] {
    let invoiceDetails = model.invoiceDetails
    let balanceModel = model.balanceModel
    let paymentMethods = model.paymentMethods
    let items: [Summary.Item] = invoiceDetails.items.map { Summary.Item(description: $0.description,
                                                                        product: $0.productSku,
                                                                        amount: $0.displayAmount) }
    let summary = Summary(referenceType: invoiceDetails.referenceType,
                          referenceId: invoiceDetails.referenceId,
                          amount: invoiceDetails.displayAmount,
                          items: items,
                          isLoading: false)
    
    let payment: Payment
    if invoiceDetails.isVirtual {
      let items: [Payment.Item] = [
        Payment.Item(title: L.walletBalance,
                     subTitle: balanceModel.display,
                     isSelected: true,
                     canSelect: false)
      ]
      payment = Payment(items: items, isPayButtonEnabled: true)
    } else {
      let items: [Payment.Item] = paymentMethods.enumerated().map { index, value in
        return Payment.Item(title: value.display,
                            subTitle: nil,
                            isSelected: false,
                            canSelect: true)
      }
      payment = Payment(items: items, isPayButtonEnabled: false)
    }
    
    return [.summary(summary), .payment(payment)]
  }
  
}
