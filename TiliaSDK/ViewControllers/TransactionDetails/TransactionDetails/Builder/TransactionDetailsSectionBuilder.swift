//
//  TransactionDetailsSectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 22.08.2022.
//

import UIKit

struct TransactionDetailsSectionBuilder {
  
  struct Section {
    
    enum SectionType {
      
      struct Header {
        
        struct Status {
          let image: UIImage?
          let imageColor: UIColor
          let title: String
          let subTitle: String?
        }
        
        struct Footer {
          let title: String
          let value: String
        }
        
        let image: UIImage?
        let title: NSAttributedString
        let subTitle: String
        let status: Status?
        var footer: Footer?
      }
      
      struct Content {
        
        struct Footer {
          let isPrimaryButtonHidden: Bool
        }
        
        let title: String
        let footer: Footer?
      }
      
      case header(Header)
      case content(Content)
      
      var backgroundColor: UIColor {
        switch self {
        case .header: return .backgroundDarkerColor
        case .content: return .backgroundColor
        }
      }
    }
    
    struct Item {
      
      struct Image {
        let image: UIImage?
        let color: UIColor
      }
      
      let title: String
      let value: String?
      let image: Image?
      let leftInset: CGFloat
      var isDividerHidden: Bool
    }
    
    let type: SectionType
    let items: [Item]
  }
  
  func numberOfRows(in section: Section) -> Int {
    return section.items.count
  }
  
  func heightForFooter(in section: Section) -> CGFloat {
    switch section.type {
    case .header:
      return UITableView.automaticDimension
    case let .content(model):
      return model.footer == nil ? .leastNormalMagnitude : UITableView.automaticDimension
    }
  }
  
  func cell(for section: Section,
            in tableView: UITableView,
            at indexPath: IndexPath) -> UITableViewCell {
    let item = section.items[indexPath.row]
    let cell = tableView.dequeue(TransactionDetailsCell.self, for: indexPath)
    cell.configure(title: item.title,
                   value: item.value,
                   image: item.image?.image,
                   color: item.image?.color,
                   leftInset: item.leftInset,
                   isDividerHidden: item.isDividerHidden)
    cell.backgroundColor = section.type.backgroundColor
    cell.contentView.backgroundColor = section.type.backgroundColor
    return cell
  }
  
  func header(for section: Section,
              in tableView: UITableView) -> UIView {
    switch section.type {
    case let .header(model):
      let view = tableView.dequeue(TransactionDetailsHeaderView.self)
      view.configure(image: model.image,
                     title: model.title,
                     subTitle: model.subTitle,
                     statusImage: model.status?.image,
                     statusImageColor: model.status?.imageColor,
                     statusTitle: model.status?.title,
                     statusSubTitle: model.status?.subTitle)
      return view
    case let .content(model):
      let view = tableView.dequeue(TransactionDetailsTitleHeaderView.self)
      view.configure(title: model.title)
      return view
    }
  }
  
  func footer(for section: Section,
              in tableView: UITableView,
              delegate: ButtonsViewDelegate) -> UIView? {
    switch section.type {
    case let .header(model):
      let view = tableView.dequeue(TransactionDetailsTitleFooterView.self)
      view.configure(title: model.footer?.title,
                     value: model.footer?.value)
      return view
    case let .content(model):
      if let footer = model.footer {
        let view = tableView.dequeue(TransactionDetailsFooterView.self)
        view.configure(isPrimaryButtonHidden: footer.isPrimaryButtonHidden,
                       delegate: delegate)
        return view
      } else {
        return nil
      }
    }
  }
  
  func sections(with model: TransactionDetailsModel) -> [Section] {
    var sections: [Section] = []
    sections.append(headerSection(for: model))
    sections.append(contentsOf: paymentSections(for: model))
    sections.append(invoiceDetailsSection(for: model))
    return sections
  }
  
}

// MARK: - Private Methods

private extension TransactionDetailsSectionBuilder {
  
  func headerSection(for model: TransactionDetailsModel) -> Section {
    var headerModel = Section.SectionType.Header(image: model.type.image,
                                                 title: headerAttributedDescription(for: model),
                                                 subTitle: formattedDate(for: model),
                                                 status: status(for: model),
                                                 footer: nil)
    switch model.type {
    case .tokenPurchase where model.isPoboSourcePaymentMethodProvider, .tokenConvert:
      return .init(type: .header(headerModel), items: [])
    default:
      var items: [Section.Item] = []
      if let lineItems = model.lineItems {
        items = lineItems.map { .init(title: $0.description,
                                      value: $0.displayAmount,
                                      image: nil,
                                      leftInset: 16,
                                      isDividerHidden: false) }
      } else if let recipientItems = model.recipientItems {
        items = recipientItems.map { .init(title: $0.description,
                                           value: $0.displayAmount,
                                           image: nil,
                                           leftInset: 16,
                                           isDividerHidden: false) }
      } else if let refundLineItems = model.refundLineItems {
        items = refundLineItems.map { .init(title: $0.description,
                                            value: $0.displayAmount,
                                            image: nil,
                                            leftInset: 16,
                                            isDividerHidden: false) }
      }
      if model.type == .tokenPurchase {
        items.append(.init(title: L.tokenPurchase,
                           value: model.total.subTotal ?? model.total.total,
                           image: nil,
                           leftInset: 16,
                           isDividerHidden: false))
      }
      model.total.subTotal.map {
        items.append(.init(title: model.type.headerSubTotalTitle,
                           value: $0,
                           image: nil,
                           leftInset: 16,
                           isDividerHidden: true))
      }
      model.total.tax.map {
        items.append(.init(title: model.type.taxTitle,
                           value: $0,
                           image: nil,
                           leftInset: 16,
                           isDividerHidden: false))
        
      }
      model.total.tiliaFee.map {
        items.append(.init(title: L.tiliaFees,
                           value: $0,
                           image: nil,
                           leftInset: 16,
                           isDividerHidden: false))
      }
      model.total.publisherFee.map {
        items.append(.init(title: L.publisherFees,
                           value: $0,
                           image: nil,
                           leftInset: 16,
                           isDividerHidden: false))
      }
      headerModel.footer = .init(title: L.total, value: model.total.total)
      return .init(type: .header(headerModel), items: items)
    }
  }
  
  func invoiceDetailsSection(for model: TransactionDetailsModel) -> Section {
    var items: [Section.Item] = [
      .init(title: L.status,
            value: model.status.description,
            image: .init(image: model.status.icon, color: model.status.color),
            leftInset: 32,
            isDividerHidden: false),
      .init(title: L.transactionId,
            value: model.id,
            image: nil,
            leftInset: 32,
            isDividerHidden: false),
      .init(title: L.accountId,
            value: model.accountId,
            image: nil,
            leftInset: 32,
            isDividerHidden: false)
      ]
      
    model.referenceType.map {
      items.append(.init(title: L.referenceType,
                         value: $0,
                         image: nil,
                         leftInset: 32,
                         isDividerHidden: false))
    }
    model.referenceId.map {
      items.append(.init(title: L.referenceId,
                         value: $0,
                         image: nil,
                         leftInset: 32,
                         isDividerHidden: false))
    }
    
    if let createdDate = model.createdDate {
      items.append(contentsOf: [
        .init(title: L.requestDate,
                           value: createdDate.longDateDescription(showTimeZone: false),
                           image: nil,
                           leftInset: 32,
                           isDividerHidden: false),
        .init(title: L.requestTime,
                           value: createdDate.shortTimeDescription(),
                           image: nil,
                           leftInset: 32,
                           isDividerHidden: model.status == .pending)
      ])
      if model.status != .pending {
        items.append(contentsOf: [
          .init(title: L.processedDate,
                             value: model.transactionDate.longDateDescription(showTimeZone: false),
                             image: nil,
                             leftInset: 32,
                             isDividerHidden: false),
          .init(title: L.processedTime,
                             value: model.transactionDate.shortTimeDescription(),
                             image: nil,
                             leftInset: 32,
                             isDividerHidden: true)
        ])
      }
    } else {
      items.append(contentsOf: [
        .init(title: L.transactionDate,
                           value: model.transactionDate.longDateDescription(showTimeZone: false),
                           image: nil,
                           leftInset: 32,
                           isDividerHidden: false),
        .init(title: L.transactionTime,
                           value: model.transactionDate.shortTimeDescription(),
                           image: nil,
                           leftInset: 32,
                           isDividerHidden: true)
      ])
    }
    
    let type = Section.SectionType.content(.init(title: L.invoiceDetails,
                                                 footer: .init(isPrimaryButtonHidden: model.status.isPrimaryButtonHidden)))
    return .init(type: type, items: items)
  }
  
  func paymentSections(for model: TransactionDetailsModel) -> [Section] {
    var sections: [Section] = []
    
    sourcePaymentMethod(for: model).map {
      let items = [Section.Item(title: $0,
                                value: sourcePaymentAmount(for: model),
                                image: nil,
                                leftInset: 32,
                                isDividerHidden: true)]
      sections.append(.init(type: .content(.init(title: model.type.sourcePaymentMethodDescription ?? "", footer: nil)),
                            items: items))
    }
    
    var items: [Section.Item] = []
    if let paymentMethods = model.paymentMethods {
      items = paymentMethods.enumerated().map { .init(title: $0.element.title,
                                                      value: $0.element.amount,
                                                      image: nil,
                                                      leftInset: 32,
                                                      isDividerHidden: $0.offset == paymentMethods.count - 1) }
    } else if let recipientItems = model.recipientItems {
      items = recipientItems.enumerated().map { .init(title: $0.element.paymentMethodDescription,
                                                      value: $0.element.paymentMethodDisplayAmount,
                                                      image: nil,
                                                      leftInset: 32,
                                                      isDividerHidden: $0.offset == recipientItems.count - 1) }
    } else if let refundPaymentMethods = model.refundPaymentMethods {
      items = refundPaymentMethods.enumerated().map { .init(title: $0.element.description,
                                                            value: $0.element.isPoboSourcePaymentMethodProvider ? nil : $0.element.displayAmount,
                                                            image: nil,
                                                            leftInset: 32,
                                                            isDividerHidden: $0.offset == refundPaymentMethods.count - 1) }
    } else if let destinationPaymentMethod = model.destinationPaymentMethod {
      items.append(.init(title: destinationPaymentMethod,
                         value: destinationPaymentAmount(for: model),
                         image: nil,
                         leftInset: 32,
                         isDividerHidden: true))
    }
    
    sections.append(.init(type: .content(.init(title: model.type.destinationPaymentMethodDescription, footer: nil)),
                          items: items))
    return sections
  }
  
  
  func formattedDate(for model: TransactionDetailsModel) -> String {
    if let createdDate = model.createdDate {
      return createdDate.formattedRequestedDescription()
    } else {
      return model.transactionDate.formattedDefaultDescription()
    }
  }
  
  func status(for model: TransactionDetailsModel) -> Section.SectionType.Header.Status? {
    guard model.type == .payout else { return nil }
    let subTitle = model.status.isFailed ? L.payoutErrorMessage : nil
    return .init(image: model.status.icon,
                 imageColor: model.status.color,
                 title: model.status.description,
                 subTitle: subTitle)
  }
  
  func headerAttributedDescription(for model: TransactionDetailsModel) -> NSAttributedString {
    let str: String
    let arguments: [String]
    switch model.type {
    case .userPurchase, .userPurchaseEscrow:
      arguments = [model.total.total]
      str = L.youPaid(with: arguments.map { $0 as CVarArg })
    case .userPurchaseRecipient:
      arguments = [model.total.total]
      str = L.youReceived(with: arguments.map { $0 as CVarArg })
    case .payout:
      arguments = [model.total.subTotal ?? ""]
      str = L.payoutOf(with: arguments.map { $0 as CVarArg })
    case .tokenPurchase:
      arguments = [model.userReceivedAmount ?? ""]
      str = L.youPurchased(with: arguments.map { $0 as CVarArg })
    case .tokenConvert:
      arguments = [model.total.total, model.userReceivedAmount ?? ""]
      str = L.convertedTo(with: arguments.map { $0 as CVarArg })
    case .refund:
      arguments = [model.total.total]
      str = L.refundOf(with: arguments.map { $0 as CVarArg })
    }
    let subStrings: [(String, UIFont, UIColor)] = arguments.map {
      return ($0, .systemFont(ofSize: 20, weight: .semibold), .primaryTextColor)
    }
    return str.attributedString(font: .systemFont(ofSize: 20),
                                color: .primaryTextColor,
                                subStrings: subStrings)
  }
  
  func sourcePaymentMethod(for model: TransactionDetailsModel) -> String? {
    return model.sourcePaymentMethod.map { model.isPoboSourcePaymentMethodProvider ? L.processedBy(with: $0) : $0 }
  }
  
  func sourcePaymentAmount(for model: TransactionDetailsModel) -> String? {
    return model.isPoboSourcePaymentMethodProvider ? nil : model.total.total
  }
  
  func destinationPaymentAmount(for model: TransactionDetailsModel) -> String {
    return model.userReceivedAmount ?? model.total.total
  }
  
}

// MARK: - Helpers

private extension TransactionStatusModel {
  
  var icon: UIImage? {
    switch self {
    case .pending: return .pendingIcon
    case .processed: return .successIcon
    case .payoutFailed, .error: return .failureIcon
    }
  }
  
  var color: UIColor {
    switch self {
    case .pending, .processed: return .primaryColor
    case .payoutFailed, .error: return .failureBackgroundColor
    }
  }
  
  var isPrimaryButtonHidden: Bool {
    switch self {
    case .pending, .payoutFailed, .error: return true
    case .processed: return false
    }
  }
  
}

private extension TransactionTypeModel {
  
  var image: UIImage? {
    switch self {
    case .userPurchase, .userPurchaseEscrow: return .buyerPurchaseIcon
    case .userPurchaseRecipient: return .sellerPurchaseIcon
    case .payout: return .payoutGenericIcon
    case .tokenPurchase: return .tokenPurchaseIcon
    case .tokenConvert: return .tokenConvertIcon
    case .refund: return .refundIcon
    }
  }
  
  var sourcePaymentMethodDescription: String? {
    switch self {
    case .tokenPurchase: return L.paidWith
    case .tokenConvert: return L.transferredFrom
    default: return nil
    }
  }
  
  var destinationPaymentMethodDescription: String {
    switch self {
    case .userPurchase, .userPurchaseEscrow:
      return L.paidWith
    case .userPurchaseRecipient, .tokenPurchase, .tokenConvert:
      return L.depositedInto
    case .payout:
      return L.payoutTo
    case .refund:
      return L.refundTo
    }
  }
  
  var headerSubTotalTitle: String {
    return self == .payout ? L.requested : L.subtotal
  }
  
  var taxTitle: String {
    switch self {
    case .payout: return L.fees
    case .userPurchaseRecipient: return L.transactionFees
    default: return L.tax
    }
  }
  
}
