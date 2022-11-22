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
    }
    
    struct Payment {
      
      struct Item {
        let title: String
        let isWallet: Bool
        var isSelected: Bool
        var isEnabled: Bool
        let icon: UIImage?
        let isDividerHidden: Bool
      }
      
      var items: [Item]
      var isPayButtonEnabled: Bool
      let payButtonTitle: String
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
      if item.isWallet {
        let newCell = tableView.dequeue(CheckoutWalletCell.self, for: indexPath)
        newCell.configure(image: item.icon,
                          title: item.title,
                          isDividerHidden: item.isDividerHidden,
                          delegate: delegate)
        newCell.configure(isOn: item.isSelected)
        newCell.configure(isEnabled: item.isEnabled)
        cell = newCell
      } else {
        let newCell = tableView.dequeue(CheckoutPaymentMethodCell.self, for: indexPath)
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
              isEnabled: false,
              icon: .walletIcon,
              isDividerHidden: true)
      ]
      payment = .init(items: items,
                      isPayButtonEnabled: true,
                      payButtonTitle: L.pay,
                      isCreditCardButtonHidden: true)
    } else {
      let count = paymentMethods.count
      let items: [Section.Payment.Item] = paymentMethods.enumerated().map { index, value in
        return .init(title: value.type.isWallet ? L.useYourBalance(with: walletBalance.display) : value.display,
                     isWallet: value.type.isWallet,
                     isSelected: false,
                     isEnabled: true,
                     icon: value.type.icon,
                     isDividerHidden: index == count - 1)
      }
      payment = .init(items: items,
                      isPayButtonEnabled: false,
                      payButtonTitle: L.usePaymentMethods,
                      isCreditCardButtonHidden: false)
    }
    
    return [.summary(summary), .payment(payment)]
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
  
  func updatePaymentSection(for section: inout [Section],
                            in tableView: UITableView,
                            at index: Int,
                            isSelected: Bool) {
    switch section[1] {
    case var .payment(model):
      model.items[index].isSelected = isSelected
      let indexPath = IndexPath(row: index, section: 1)
      if let cell = tableView.cellForRow(at: indexPath) as? CheckoutPaymentMethodCell, !isSelected {
        cell.configure(isSelected: isSelected)
      }
      if let cell = tableView.cellForRow(at: indexPath) as? CheckoutWalletCell, !isSelected {
        cell.configure(isOn: isSelected)
      }
      section[1] = .payment(model)
    default:
      break
    }
  }
  
  func updatePaymentSection(for section: inout [Section],
                            in tableView: UITableView,
                            isEnabled: Bool) {
    switch section[1] {
    case var .payment(model):
      for index in 0..<model.items.count {
        model.items[index].isEnabled = isEnabled
        let indexPath = IndexPath(row: index, section: 1)
        if let cell = tableView.cellForRow(at: indexPath) as? CheckoutPaymentMethodCell {
          cell.configure(isEnabled: isEnabled)
        }
      }
      section[1] = .payment(model)
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
      if let footer = tableView.footerView(forSection: 1) as? CheckoutPaymentFooterView {
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
