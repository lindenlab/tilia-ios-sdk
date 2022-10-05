//
//  UIViewController+Childs.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 04.10.2022.
//

import UIKit

extension UIViewController {
  
  func addAsChildViewController(_ viewController: UIViewController) {
    addChild(viewController)
    view.addSubview(viewController.view)
    viewController.view.frame.size = view.bounds.size
    viewController.didMove(toParent: self)
  }
  
  func removeAsChildViewController() {
    willMove(toParent: nil)
    view.removeFromSuperview()
    removeFromParent()
  }
  
}
