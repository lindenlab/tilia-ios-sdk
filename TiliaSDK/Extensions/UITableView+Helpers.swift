//
//  UITableView+Helpers.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 31.03.2022.
//

import UIKit

extension UITableView {
  
  func register<T>(_ viewClass: T.Type) where T: UITableViewHeaderFooterView {
    register(viewClass, forHeaderFooterViewReuseIdentifier: viewClass.reuseIdentifier)
  }
  
  func register<T>(_ cellClass: T.Type) where T: UITableViewCell {
    register(cellClass, forCellReuseIdentifier: cellClass.reuseIdentifier)
  }
  
  func dequeue<T>(_ viewClass: T.Type) -> T where T: UITableViewHeaderFooterView {
    dequeueReusableHeaderFooterView(withIdentifier: viewClass.reuseIdentifier) as! T
  }
  
  func dequeue<T>(_ cellClass: T.Type, for indexPath: IndexPath) -> T where T: UITableViewCell {
    dequeueReusableCell(withIdentifier: cellClass.reuseIdentifier, for: indexPath) as! T
  }
  
}
