//
//  CheckoutSectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 01.04.2022.
//

import UIKit

struct CheckoutSectionBuilder {
  
  typealias CellDelegate = CheckoutWalletCellDelegate & CheckoutPaymentMethodCellDelegate
  typealias FooterDelegate = CheckoutPaymentFooterViewDelegate & TextViewWithLinkDelegate
  
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
      var isLoading: Bool
    }
    
    struct Payment {
      
      struct Item {
        let title: String
        let isWallet: Bool
        var isSelected: Bool
        let icon: UIImage?
        let isDividerHidden: Bool
      }
      
      var items: [Item]
      var isPayButtonEnabled: Bool
      let payButtonTitle: String
      let isCreditCardButtonHidden: Bool
      let canSelect: Bool
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
            delegate: CellDelegate) -> UITableViewCell {
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
      if item.isWallet {
        let cell = tableView.dequeue(CheckoutWalletCell.self, for: indexPath)
        cell.configure(value: item.title,
                       isOn: item.isSelected,
                       isDividerHidden: item.isDividerHidden,
                       delegate: delegate)
        return cell
      } else {
        let cell = tableView.dequeue(CheckoutPaymentMethodCell.self, for: indexPath)
        cell.configure(title: item.title,
                       canSelect: model.canSelect,
                       isDividerHidden: item.isDividerHidden,
                       icon: item.icon,
                       delegate: delegate)
        cell.configure(isSelected: item.isSelected)
        return cell
      }
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
              delegate: FooterDelegate) -> UIView {
    switch section {
    case let .summary(model):
      let view = tableView.dequeue(CheckoutPayloadSummaryFooterView.self)
      view.configure(amount: model.amount)
      view.configure(isLoading: model.isLoading)
      return view
    case let .payment(model):
      let view = tableView.dequeue(CheckoutPaymentFooterView.self)
      view.configure(payButtonTitle: model.isEmpty ? nil : model.payButtonTitle,
                     closeButtonTitle: L.cancel,
                     isCreditCardButtonHidden: model.isCreditCardButtonHidden,
                     delegate: delegate,
                     textViewDelegate: model.isEmpty ? nil : delegate)
      view.configure(isPayButtonEnabled: model.isPayButtonEnabled)
      return view
    case .successfulPayment:
      let view = tableView.dequeue(CheckoutPaymentFooterView.self)
      view.configure(payButtonTitle: nil,
                     closeButtonTitle: L.done,
                     isCreditCardButtonHidden: true,
                     delegate: delegate,
                     textViewDelegate: nil)
      return view
    }
  }
  
  func sections(with model: CheckoutContent) -> [Section] {
    let invoiceInfo = model.invoiceInfo
    let walletBalance = model.walletBalance
    let paymentMethods = model.paymentMethods
    let summary = summaryModel(for: invoiceInfo)
    
    let payment: Section.Payment
    if model.isVirtual {
      let items: [Section.Payment.Item] = [
        .init(title: walletBalance.display,
              isWallet: true,
              isSelected: true,
              icon: .walletIcon,
              isDividerHidden: true)
      ]
      payment = .init(items: items,
                      isPayButtonEnabled: true,
                      payButtonTitle: L.pay,
                      isCreditCardButtonHidden: true,
                      canSelect: false)
    } else {
      let count = paymentMethods.count
      let items: [Section.Payment.Item] = paymentMethods.enumerated().map { index, value in
        return .init(title: value.type.isWallet ? walletBalance.display : value.display,
                     isWallet: value.type.isWallet,
                     isSelected: false,
                     icon: value.type.icon,
                     isDividerHidden: index == count - 1)
      }
      payment = .init(items: items,
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
  
  func updatedSummarySection(for section: Section,
                             model: InvoiceInfoModel) -> Section {
    switch section {
    case .summary:
      let summary = summaryModel(for: model)
      return .summary(summary)
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
      if let cell = tableView.cellForRow(at: indexPath) as? CheckoutPaymentMethodCell, !isSelected {
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
        footer.configure(isPayButtonEnabled: isPayButtonEnabled)
      }
      return .payment(model)
    default:
      return section
    }
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
                 items: items,
                 isLoading: false)
  }
  
}

// MARK: - Helpers

private extension CheckoutPaymentTypeModel {
  
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
