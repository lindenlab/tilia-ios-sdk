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
    var isLoading: Bool
  }
  
  struct Payment {
    
    struct Item {
      let title: String
      let subTitle: String?
      var isSelected: Bool
      let icon: UIImage?
    }
    
    var items: [Item]
    var isPayButtonEnabled: Bool
    let payButtonTitle: String
    let canSelect: Bool
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
    
  }
  
  func cell(for section: Section,
            in tableView: UITableView,
            at indexPath: IndexPath,
            delegate: CheckoutPaymentMethodCellDelegate?) -> UITableViewCell {
    switch section {
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
      let lastItemIndex = tableView.numberOfRows(inSection: indexPath.section) - 1
      cell.configure(title: item.title,
                     subTitle: item.subTitle,
                     isSelected: item.isSelected,
                     canSelect: model.canSelect,
                     isDividerHidden: lastItemIndex == indexPath.row,
                     icon: item.icon,
                     delegate: delegate)
      return cell
    case .successfulPayment:
      return tableView.dequeue(CheckoutSuccessfulPaymentCell.self, for: indexPath)
    }
  }
  
  func header(for section: Section,
              in tableView: UITableView) -> UIView? {
    switch section {
    case .summary:
      let view = tableView.dequeue(ChekoutTitleHeaderView.self)
      // TODO: - Temporary remove
//      view.configure(title: L.transactionSummary,
//                     subTitle: "\(invoiceModel.referenceType) \(invoiceModel.referenceId)")
      view.configure(title: L.transactionSummary, subTitle: nil)
      return view
    case .payment:
      let view = tableView.dequeue(ChekoutTitleHeaderView.self)
      view.configure(title: L.choosePaymentMethod, subTitle: nil)
      return view
    case .successfulPayment:
      return nil
    }
  }
  
  func footer(for section: Section,
              in tableView: UITableView,
              delegate: CheckoutPaymentFooterViewDelegate?,
              textViewDelegate: TextViewWithLinkDelegate?) -> UIView {
    switch section {
    case let .summary(model):
      let view = tableView.dequeue(CheckoutPayloadSummaryFooterView.self)
      view.configure(amount: model.amount, isLoading: model.isLoading)
      return view
    case let .payment(model):
      let view = tableView.dequeue(CheckoutPaymentFooterView.self)
      view.configure(payButtonTitle: model.payButtonTitle,
                     closeButtonTitle: L.cancel,
                     isPrimaryButtonEnabled: model.isPayButtonEnabled,
                     delegate: delegate,
                     textViewDelegate: textViewDelegate)
      return view
    case .successfulPayment:
      let view = tableView.dequeue(CheckoutPaymentFooterView.self)
      view.configure(payButtonTitle: nil,
                     closeButtonTitle: L.done,
                     isPrimaryButtonEnabled: true,
                     delegate: delegate,
                     textViewDelegate: nil)
      return view
    }
  }
  
  func sections(with model: CheckoutContent) -> [Section] {
    let invoiceDetails = model.invoiceDetails
    let walletBalance = model.walletBalance
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
                     subTitle: walletBalance?.display,
                     isSelected: true,
                     icon: .walletIcon)
      ]
      payment = Payment(items: items,
                        isPayButtonEnabled: true,
                        payButtonTitle: L.pay,
                        canSelect: false)
    } else {
      let items: [Payment.Item] = paymentMethods.enumerated().map { index, value in
        return Payment.Item(title: value.type.isWallet ? L.walletBalance : value.display,
                            subTitle: value.type.isWallet ? walletBalance?.display : nil,
                            isSelected: false,
                            icon: value.type.icon)
      }
      payment = Payment(items: items,
                        isPayButtonEnabled: false,
                        payButtonTitle: L.usePaymentMethods,
                        canSelect: true)
    }
    
    return [.summary(summary), .payment(payment)]
  }
  
  func successfulPaymentSection() -> Section {
    return .successfulPayment
  }
  
  func updatedSummarySection(for section: Section,
                             in tableView: UITableView,
                             at sectionIndex: Int,
                             isLoading: Bool) -> Section {
    switch section {
    case var .summary(model):
      model.isLoading = isLoading
      let footerView = tableView.footerView(forSection: sectionIndex) as? CheckoutPayloadSummaryFooterView
      footerView?.configure(isLoading: isLoading)
      return .summary(model)
    default:
      return section
    }
  }
  
  func updatedPaymentSection(for section: Section,
                             in tableView: UITableView,
                             at indexPath: IndexPath,
                             isSelected: Bool) -> Section {
    switch section {
    case var .payment(model):
      model.items[indexPath.row].isSelected = isSelected
      let cell = tableView.cellForRow(at: indexPath) as? CheckoutPaymentMethodCell
      cell?.configure(isSelected: isSelected)
      return .payment(model)
    default:
      return section
    }
  }
  
  func updatedPaymentSection(for section: Section,
                             in tableView: UITableView,
                             at sectionIndex: Int,
                             isPayButtonEnabled: Bool) -> Section {
    switch section {
    case var .payment(model):
      model.isPayButtonEnabled = isPayButtonEnabled
      let footer = tableView.footerView(forSection: sectionIndex) as? CheckoutPaymentFooterView
      footer?.configure(isPrimaryButtonEnabled: isPayButtonEnabled)
      return .payment(model)
    default:
      return section
    }
  }
  
}

// MARK: - Helpers

private extension PaymentTypeModel {
  
  var icon: UIImage? {
    switch self {
    case .wallet: return .walletIcon
    case .paypal: return nil
    case .americanExpress: return .americanExpressIcon
    case .discover: return .discoverIcon
    case .dinersClub: return .dinersClubIcon
    case .jcb: return .jcbIcon
    case .maestro: return .maestroIcon
    case .electron: return nil
    case .masterCard: return .masterCardIcon
    case .visa: return .visaIcon
    case .chinaUnionpay: return .chinaUnionpayIcon
    }
  }
  
}
