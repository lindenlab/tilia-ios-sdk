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
    var sections = [headerSection(for: model)]
    sections.append(contentsOf: paymentSections(for: model))
    sections.append(invoiceDetailsSection(for: model))
    return sections
  }
  
}

// MARK: - Private Methods

private extension TransactionDetailsSectionBuilder {
  
  func headerSection(for model: TransactionDetailsModel) -> Section {
    var items: [Section.Item] = model.items.map { .init(title: $0.description,
                                                        value: $0.displayAmount,
                                                        image: nil,
                                                        leftInset: 16,
                                                        isDividerHidden: false) }
    
    model.subTotal.map {
      items.append(contentsOf: [
        .init(title: L.subtotal,
                           value: $0.total,
                           image: nil,
                           leftInset: 16,
                           isDividerHidden: true),
        .init(title: L.transactionFees,
                           value: $0.tax,
                           image: nil,
                           leftInset: 16,
                           isDividerHidden: false)
      ])
    }
    
    let type = Section.SectionType.header(.init(image: model.role.image,
                                                title: model.role.attributedDescription(amount: model.total),
                                                subTitle: model.createDate.formattedDescription(),
                                                status: nil,
                                                footer: .init(title: L.total, value: model.total)))
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
    
    model.reference.map {
      items.append(contentsOf: [
        .init(title: L.referenceType,
              value: $0.type,
                           image: nil,
                           leftInset: 32,
                           isDividerHidden: false),
        .init(title: L.referenceId,
              value: $0.id,
                           image: nil,
                           leftInset: 32,
                           isDividerHidden: false)
      ])
    }
    
    items.append(contentsOf: [
      .init(title: L.transactionDate,
                         value: DateFormatter.longDateFormatter.string(from: model.createDate),
                         image: nil,
                         leftInset: 32,
                         isDividerHidden: false),
      .init(title: L.transactionTime,
            value: DateFormatter.shortTimeFormatter.string(from: model.createDate),
            image: nil,
            leftInset: 32,
            isDividerHidden: true)

      
    ])
    
    let type = Section.SectionType.content(.init(title: L.invoiceDetails,
                                                 footer: .init(isPrimaryButtonHidden: false)))
    return .init(type: type, items: items)
  }
  
  func paymentSections(for model: TransactionDetailsModel) -> [Section] {
    // TODO: - Here is must be different number of sections
    let items: [Section.Item] = model.paymentMethods.enumerated().map { .init(title: $0.element.type.description,
                                                                              value: $0.element.displayAmount,
                                                                              image: nil,
                                                                              leftInset: 32,
                                                                              isDividerHidden: $0.offset == model.paymentMethods.count - 1) }
    let type = Section.SectionType.content(.init(title: model.role.description,
                                                 footer: nil))
    return [.init(type: type, items: items)]
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

private extension TransactionRole {
  
  func attributedDescription(amount: String) -> NSAttributedString {
    let str: String
    switch self {
    case .buyer: str = L.youPaid(with: amount)
    case .seller: str = L.youReceived(with: amount)
    }
    return str.attributedString(font: .systemFont(ofSize: 20),
                                color: .primaryTextColor,
                                subStrings: (amount, .systemFont(ofSize: 20, weight: .semibold), .primaryTextColor))
  }
  
  var image: UIImage? {
    switch self {
    case .buyer: return .purchaseBuyerIcon
    case .seller: return .purchaseSellerIcon
    }
  }
  
  var description: String {
    switch self {
    case .buyer: return L.paidWith
    case .seller: return L.depositedInto
    }
  }
  
}
