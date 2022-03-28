//
//  BaseViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 28.03.2022.
//

import UIKit

open class TLBaseViewController: UIViewController {
  
  var isLoading: Bool {
    get {
      return spinner.isAnimating
    }
    set {
      newValue ? spinner.startAnimating() : spinner.stopAnimating()
      newValue ? view.addSubview(containerView) : containerView.removeFromSuperview()
    }
  }
  
  private lazy var containerView: UIView = {
    let view = UIView(frame: self.view.frame)
    view.backgroundColor = self.view.backgroundColor
    return view
  }()
  
  private lazy var spinner: UIActivityIndicatorView = {
    let spinner = UIActivityIndicatorView(style: .large)
    spinner.startAnimating()
    containerView.addSubview(spinner)
    spinner.center = containerView.center
    return spinner
  }()
  
}
