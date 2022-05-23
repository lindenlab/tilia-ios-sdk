//
//  UserDocumentsSectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 18.05.2022.
//

import UIKit

struct UserDocumentsSectionBuilder {
  
  typealias CellDelegate = TextFieldsCellDelegate
  typealias SectionFooterDelegate = ButtonsViewDelegate
  
  struct Section {
    
    enum SectionType {
      case documents
      case success
    }
    
    struct Item {
      
    }
    
    let type: SectionType
    var items: [Item]
  }
  
  func numberOfRows(in section: Section) -> Int {
    return section.items.count
  }
  
  func cell(for section: Section,
            in tableView: UITableView,
            at indexPath: IndexPath,
            delegate: CellDelegate) -> UITableViewCell {
    return UITableViewCell()
  }
  
  func header(for section: Section,
              in tableView: UITableView) -> UIView {
    let view = tableView.dequeue(TitleInfoHeaderFooterView.self)
    switch section.type {
    case .documents:
      view.configure(title: L.almostThere, subTitle: L.userDocumentsMessage)
    case .success:
      view.configure(title: L.allSet, subTitle: L.userDocumentsSuccessMessage)
    }
    return view
  }
  
  func footer(for section: Section,
              in tableView: UITableView,
              delegate: SectionFooterDelegate) -> UIView {
    let view = tableView.dequeue(UserDocumentsFooterView.self)
    switch section.type {
    case .documents:
      view.configure(isPrimaryButtonEnabled: false, delegate: delegate)
    case .success:
      view.configure(isPrimaryButtonEnabled: false, delegate: nil) // TODO: - Fix me
    }
    return view
  }
  
  func documetsSection() -> Section {
    return Section(type: .documents, items: [])
  }
  
  func successSection() -> Section {
    return Section(type: .success, items: [])
  }
  
}
