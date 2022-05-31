//
//  UICollectionView+Helpers.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 31.05.2022.
//

import UIKit

extension UICollectionView {
  
  func register<T>(_ cellClass: T.Type) where T: UICollectionViewCell {
    register(cellClass, forCellWithReuseIdentifier: cellClass.reuseIdentifier)
  }
  
  func dequeue<T>(_ cellClass: T.Type, for indexPath: IndexPath) -> T where T: UICollectionViewCell {
    dequeueReusableCell(withReuseIdentifier: cellClass.reuseIdentifier, for: indexPath) as! T
  }
  
}
