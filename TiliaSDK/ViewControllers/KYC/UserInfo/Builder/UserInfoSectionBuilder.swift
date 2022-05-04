//
//  UserInfoSectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 04.05.2022.
//

import UIKit

struct UserInfoSectionBuilder {
  
  struct Expandable {
    let title: String
    let mode: UserInfoHeaderView.Mode
  }
  
  enum Section {
    case header
    case expandable(Expandable)
    case footer
    
    var numberOfRows: Int {
      switch self {
      case .expandable: return 0
      default: return 0
      }
    }
  }
  
  func header(for section: Section,
              in tableView: UITableView,
              userInfoHeaderViewDelegate: UserInfoHeaderViewDelegate?) -> UIView {
    switch section {
    case .header:
      let view = tableView.dequeue(TitleInfoHeaderFooterView.self)
      view.configure(title: L.userInfoTitle, subTitle: L.userInfoMessage)
      return view
    case let .expandable(model):
      let view = tableView.dequeue(UserInfoHeaderView.self)
      view.configure(title: model.title,
                     mode: model.mode,
                     delegate: userInfoHeaderViewDelegate)
      return view
    case .footer:
      return UIView() // TODO: - Add footer
    }
  }
  
  
  
}
