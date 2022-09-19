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
        let footer: Footer?
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
    }
    
    struct Item {
      
      struct Image {
        let image: UIImage?
        let color: UIColor
      }
      
      let title: String
      let value: String
      let image: Image?
      let leftInset: CGFloat
      let isDividerHidden: Bool
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
    return [
      headerSection(for: model),
      paymentSection(for: model),
      invoiceDetailsSection(for: model)
    ]
  }
  
}

// MARK: - Private Methods

private extension TransactionDetailsSectionBuilder {
  
  func headerSection(for model: TransactionDetailsModel) -> Section {
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
    }
    
    items.append(.init(title: L.subtotal,
                       value: model.total.subTotal,
                       image: nil,
                       leftInset: 16,
                       isDividerHidden: model.total.tax != nil))
    
    model.total.tax.map {
      items.append(.init(title: L.transactionFees,
                         value: $0,
                         image: nil,
                         leftInset: 16,
                         isDividerHidden: false))
    }
    
    let type = Section.SectionType.header(.init(image: model.type.image,
                                                title: model.type.attributedDescription(amount: model.total.total),
                                                subTitle: model.transactionDate.formattedDescription(),
                                                status: nil,
                                                footer: .init(title: L.total, value: model.total.total)))
    return .init(type: type, items: items)
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
    
    items.append(contentsOf: [
      .init(title: L.transactionDate,
            value: DateFormatter.longDateFormatter.string(from: model.transactionDate),
            image: nil,
            leftInset: 32,
            isDividerHidden: false),
      .init(title: L.transactionTime,
            value: DateFormatter.shortTimeFormatter.string(from: model.transactionDate),
            image: nil,
            leftInset: 32,
            isDividerHidden: true)

      
    ])
    
    let type = Section.SectionType.content(.init(title: L.invoiceDetails,
                                                 footer: .init(isPrimaryButtonHidden: false)))
    return .init(type: type, items: items)
  }
  
  func paymentSection(for model: TransactionDetailsModel) -> Section {
    let items: [Section.Item]
    if let paymentMethods = model.paymentMethods {
      items = paymentMethods.enumerated().map { .init(title: $0.element.type.description,
                                                      value: $0.element.displayAmount,
                                                      image: nil,
                                                      leftInset: 32,
                                                      isDividerHidden: $0.offset == paymentMethods.count - 1) }
    } else if let recipientItems = model.recipientItems {
      items = recipientItems.enumerated().map { .init(title: $0.element.paymentMethodDescription,
                                                      value: $0.element.paymentMethodDisplayAmount,
                                                      image: nil,
                                                      leftInset: 32,
                                                      isDividerHidden: $0.offset == recipientItems.count - 1) }
    } else {
      items = [] // TODO: - Fix me
    }
    let type = Section.SectionType.content(.init(title: model.type.description,
                                                 footer: nil))
    return .init(type: type, items: items)
  }
  
}

// MARK: - Helpers

private extension TransactionStatus {
  
  var icon: UIImage? {
    switch self {
    case .pending: return .pendingIcon
    case .processed: return .successIcon
    case .failed: return .failureIcon
    }
  }
  
  var color: UIColor {
    switch self {
    case .pending, .processed: return .primaryColor
    case .failed: return .failureBackgroundColor
    }
  }
  
}

private extension TransactionType {
  
  func attributedDescription(amount: String) -> NSAttributedString {
    let str: String
    switch self {
    case .userPurchase: str = L.youPaid(with: amount)
    case .userPurchaseRecipient: str = L.youReceived(with: amount)
    case .payout: str = L.payoutOf(with: amount)
    }
    return str.attributedString(font: .systemFont(ofSize: 20),
                                color: .primaryTextColor,
                                subStrings: (amount, .systemFont(ofSize: 20, weight: .semibold), .primaryTextColor))
  }
  
  var image: UIImage? {
    switch self {
    case .userPurchase: return .purchaseBuyerIcon
    case .userPurchaseRecipient: return .purchaseSellerIcon
    case .payout: return .payoutGenericIcon
    }
  }
  
  var description: String {
    switch self {
    case .userPurchase: return L.paidWith
    case .userPurchaseRecipient: return L.depositedInto
    case .payout: return L.payoutTo
    }
  }
  
}
