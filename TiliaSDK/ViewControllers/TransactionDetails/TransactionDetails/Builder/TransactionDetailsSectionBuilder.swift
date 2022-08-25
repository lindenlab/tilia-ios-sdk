//
//  TransactionDetailsSectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 22.08.2022.
//

import UIKit

struct TransactionDetailsSectionBuilder {
  
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
    let items: [Item]
  }
  
  struct Content {
    
    struct Footer {
      let isPrimaryButtonHidden: Bool
    }
    
    let title: String
    let footer: Footer?
    let items: [Item]
  }
  
  struct Item {
    
    struct Image {
      let image: UIImage?
      let color: UIColor
    }
    
    let title: String
    let subTitle: String?
    let value: String
    let image: Image?
    let leftInset: CGFloat
    let isDividerHidden: Bool
  }
  
  enum Section {
    case header(Header)
    case content(Content)
    
    var items: [Item] {
      switch self {
      case let .header(model): return model.items
      case let .content(model): return model.items
      }
    }
  }
  
  func numberOfRows(in section: Section) -> Int {
    return section.items.count
  }
  
  func heightForFooter(in section: Section) -> CGFloat {
    switch section {
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
                   subTitle: item.subTitle,
                   value: item.value,
                   image: item.image?.image,
                   color: item.image?.color,
                   leftInset: item.leftInset,
                   isDividerHidden: item.isDividerHidden)
    return cell
  }
  
  func header(for section: Section,
              in tableView: UITableView) -> UIView {
    switch section {
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
    switch section {
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
  
  func sections() -> [Section] {
    return purchaseSections()
  }
  
}

// MARK: - Private Methods

extension TransactionDetailsSectionBuilder {
  
  func purchaseSections() -> [Section] {
    var sections: [Section] = []
    
    let headerItems: [Item] = [
      .init(title: "2919 BRIDGE AVE, OH",
            subTitle: nil,
            value: "$10.24 USD",
            image: nil,
            leftInset: 16,
            isDividerHidden: false),
      .init(title: L.subtotal,
            subTitle: nil,
            value: "$41.86 USD",
            image: nil,
            leftInset: 16,
            isDividerHidden: true),
      .init(title: L.transactionFees,
            subTitle: nil,
            value: "$4.22 USD",
            image: nil,
            leftInset: 16,
            isDividerHidden: false)
    ]
    sections.append(.header(.init(image: .purchaseBuyerIcon, // Fix for buyer/seller
                                  title: attributedString(str: L.youPaid(with: "$46.08 USD"), subStr: "$46.08 USD"), // Fix for buyer/seller
                                  subTitle: L.todayAt(with: "4:32pm (PST)"),
                                  status: nil,
                                  footer: .init(title: L.total, value: "$46.08 USD"),
                                  items: headerItems)))
    
    
    // Fix for buyer/seller
    if true {
      let payInfoItems: [Item] = [
        .init(title: "Tilia Wallet",
              subTitle: nil,
              value: "$10.24 USD",
              image: nil,
              leftInset: 32,
              isDividerHidden: false),
        .init(title: "Visa ending in 8946",
              subTitle: "This transaction will appear on your statement as “Tilia / Upland”",
              value: "$10.24 USD",
              image: nil,
              leftInset: 32,
              isDividerHidden: true)
      ]
      sections.append(.content(.init(title: L.paidWith,
                                     footer: nil,
                                     items: payInfoItems)))
    } else {
      let payInfoItems: [Item] = [
        .init(title: "Tilia Wallet",
              subTitle: nil,
              value: "$10.24 USD",
              image: nil,
              leftInset: 32,
              isDividerHidden: false)
      ]
      sections.append(.content(.init(title: L.depositedInto,
                                     footer: nil,
                                     items: payInfoItems)))
    }
    
    let invoiceDetailsItems: [Item] = [
      .init(title: L.status,
            subTitle: nil,
            value: "Processed",
            image: .init(image: .successIcon, color: .primaryColor),
            leftInset: 32,
            isDividerHidden: false),
      .init(title: L.transactionId,
            subTitle: nil,
            value: "FK0013EA92144M9",
            image: nil,
            leftInset: 32,
            isDividerHidden: false),
      .init(title: L.referenceType,
            subTitle: nil,
            value: "Upland order",
            image: nil,
            leftInset: 32,
            isDividerHidden: false),
      .init(title: L.referenceId,
            subTitle: nil,
            value: "#3112KM95",
            image: nil,
            leftInset: 32,
            isDividerHidden: false),
      .init(title: L.transactionDate,
            subTitle: nil,
            value: "August 4th, 2022",
            image: nil,
            leftInset: 32,
            isDividerHidden: false),
      .init(title: L.transactionTime,
            subTitle: nil,
            value: "4:32pm (PST)",
            image: nil,
            leftInset: 32,
            isDividerHidden: true)
    ]
    sections.append(.content(.init(title: L.invoiceDetails,
                                   footer: .init(isPrimaryButtonHidden: false),
                                   items: invoiceDetailsItems)))
    return sections
  }
  
  func attributedString(str: String, subStr: String) -> NSAttributedString {
    return str.attributedString(font: .systemFont(ofSize: 20),
                                color: .primaryTextColor,
                                subStrings: (subStr, .systemFont(ofSize: 20, weight: .semibold), .primaryTextColor))
  }
  
}
