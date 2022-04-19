//
//  LoadableProtocol.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 29.03.2022.
//

import UIKit

protocol LoadableProtocol {
  var hideableView: UIView { get }
  var spinnerPosition: CGPoint { get }
}

// MARK: - Default Implementation

extension LoadableProtocol {
  
  func startLoading() {
    guard
      let subviews = hideableView.superview?.subviews,
      subviews.filter({ $0 is UIActivityIndicatorView }).isEmpty else { return }
    let spinner = UIActivityIndicatorView(style: .large)
    spinner.startAnimating()
    spinner.center = spinnerPosition
    hideableView.superview?.addSubview(spinner)
    hideableView.isHidden = true
  }
  
  func stopLoading() {
    hideableView.superview?.subviews.filter { $0 is UIActivityIndicatorView }.forEach { $0.removeFromSuperview() }
    hideableView.isHidden = false
  }
  
}
