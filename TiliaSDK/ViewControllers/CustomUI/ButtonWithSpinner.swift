//
//  ButtonWithSpinner.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 28.03.2022.
//

import UIKit

final class ButtonWithSpinner: UIButton {
  
  var isLoading: Bool {
    get {
      return spinner.isAnimating
    }
    set {
      if newValue { title = titleLabel?.text }
      newValue ? spinner.startAnimating() : spinner.stopAnimating()
      newValue ? setTitle(nil, for: .normal) : setTitle(title, for: .normal)
      isEnabled = !newValue
    }
  }
  
  override var isEnabled: Bool {
    get {
      return isLoading ? false : super.isEnabled
    }
    set {
      super.isEnabled = isLoading ? false : newValue
    }
  }
  
  private var title: String?
  
  private lazy var spinner: UIActivityIndicatorView = {
    let spinner = UIActivityIndicatorView(style: .medium)
    spinner.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(spinner)
    spinner.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    spinner.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    return spinner
  }()
  
}
