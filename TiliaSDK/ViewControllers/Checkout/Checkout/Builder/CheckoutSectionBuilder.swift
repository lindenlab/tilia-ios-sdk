//
//  CheckoutSectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 01.04.2022.
//

import UIKit

struct CheckoutSectionBuilder {
  
  typealias CellDelegate = CheckoutPaymentMethodCellDelegate
  typealias FooterDelegate = CheckoutPaymentFooterViewDelegate & TextViewWithLinkDelegate
  
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
    let isCreditCardButtonHidden: Bool
    let canSelect: Bool
    var isEmpty: Bool { return items.isEmpty }
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
      case let .payment(model):
        return model.isEmpty ? 20 : UITableView.automaticDimension
      default: return UITableView.automaticDimension
      }
    }
    
  }
  
  func cell(for section: Section,
            in tableView: UITableView,
            at indexPath: IndexPath,
            delegate: CellDelegate) -> UITableViewCell {
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
    case let .summary(invoiceModel):
      let view = tableView.dequeue(TitleInfoHeaderFooterView.self)
      view.configure(title: L.transactionSummary,
                     subTitle: "\(invoiceModel.referenceType) \(invoiceModel.referenceId)",
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
              delegate: FooterDelegate) -> UIView {
    switch section {
    case let .summary(model):
      let view = tableView.dequeue(CheckoutPayloadSummaryFooterView.self)
      view.configure(amount: model.amount, isLoading: model.isLoading)
      return view
    case let .payment(model):
      let view = tableView.dequeue(CheckoutPaymentFooterView.self)
      view.configure(payButtonTitle: model.isEmpty ? nil : model.payButtonTitle,
                     closeButtonTitle: L.cancel,
                     isPayButtonEnabled: model.isPayButtonEnabled,
                     isCreditCardButtonHidden: model.isCreditCardButtonHidden,
                     delegate: delegate,
                     textViewDelegate: model.isEmpty ? nil : delegate)
      return view
    case .successfulPayment:
      let view = tableView.dequeue(CheckoutPaymentFooterView.self)
      view.configure(payButtonTitle: nil,
                     closeButtonTitle: L.done,
                     isPayButtonEnabled: true,
                     isCreditCardButtonHidden: true,
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
                        isCreditCardButtonHidden: true,
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
                        isCreditCardButtonHidden: false,
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
      if let footerView = tableView.footerView(forSection: sectionIndex) as? CheckoutPayloadSummaryFooterView {
        footerView.configure(isLoading: isLoading)
      }
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
      if let cell = tableView.cellForRow(at: indexPath) as? CheckoutPaymentMethodCell {
        cell.configure(isSelected: isSelected)
      }
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
      if let footer = tableView.footerView(forSection: sectionIndex) as? CheckoutPaymentFooterView {
        footer.configure(isPrimaryButtonEnabled: isPayButtonEnabled)
      }
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
