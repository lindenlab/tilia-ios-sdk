//
//  LoadableProtocol.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 29.03.2022.
//

import UIKit

protocol LoadableProtocol {
  var hideableView: UIView { get }
  
  func startLoading()
  func stopLoading()
}

extension LoadableProtocol {
  
  func startLoading() {
    let spinner = UIActivityIndicatorView(style: .large)
    spinner.startAnimating()
    spinner.center = hideableView.center
    hideableView.superview?.addSubview(spinner)
    hideableView.isHidden = true
  }
  
  func stopLoading() {
    hideableView.superview?.subviews.filter { $0 is UIActivityIndicatorView }.forEach { $0.removeFromSuperview() }
    hideableView.isHidden = false
  }
  
}
