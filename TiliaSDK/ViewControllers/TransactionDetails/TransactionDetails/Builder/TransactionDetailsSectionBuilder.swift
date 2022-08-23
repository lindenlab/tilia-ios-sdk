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
    let title: String
    let isPrimaryButtonHidden: Bool
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
  
  func cell(for section: Section,
            in tableView: UITableView,
            at indexPath: IndexPath) -> UITableViewCell {
    let item = section.items[indexPath.row]
    let cell = tableView.dequeue(TransactionDetailsCell.self, for: indexPath)
    cell.configure(title: item.title,
                   subTitle: item.subTitle,
                   value: item.value,
                   image: item.image?.image,
                   color: item.image?.color ?? .clear,
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
              at index: Int,
              delegate: ButtonsViewDelegate) -> UIView? {
    switch section {
    case let .header(model):
      let view = tableView.dequeue(TransactionDetailsTitleFooterView.self)
      view.configure(title: model.footer?.title,
                     value: model.footer?.value)
      return view
    case let .content(model) where index != tableView.numberOfSections - 1:
      let view = tableView.dequeue(TransactionDetailsFooterView.self)
      view.configure(isPrimaryButtonHidden: model.isPrimaryButtonHidden,
                     delegate: delegate)
      return view
    default:
      return nil
    }
  }
  
  func sections() -> [Section] {
    
    return []
  }
  
}
