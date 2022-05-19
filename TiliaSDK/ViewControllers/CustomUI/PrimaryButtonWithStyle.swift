//
//  PrimaryButtonWithStyle.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 06.05.2022.
//

import UIKit

final class PrimaryButtonWithStyle: PrimaryButton {
  
  enum Style {
    case titleAndImageCenter
    case imageAndTitleCenter
  }
  
  var isLoading: Bool = false {
    didSet {
      isLoading ? addSpinner() : removeSpinner()
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
  
  private let style: Style
  private var titleForLoadingState: String?
  private var title: String?
  private var spinner: UIActivityIndicatorView?
  
  init(_ style: Style, frame: CGRect = .zero) {
    self.style = style
    super.init(frame: frame)
    switch style {
    case .titleAndImageCenter:
      semanticContentAttribute = .forceRightToLeft
      imageEdgeInsets.left = 12
    case .imageAndTitleCenter:
      imageEdgeInsets.right = 12
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    guard let spinner = spinner, let titleLabel = titleLabel else { return }
    let spinnerCenterX: CGFloat
    switch style {
    case .titleAndImageCenter:
      spinnerCenterX = titleLabel.frame.maxX + imageEdgeInsets.left
    case .imageAndTitleCenter:
      spinnerCenterX = titleLabel.frame.minX - imageEdgeInsets.right
    }
    spinner.center = CGPoint(x: spinnerCenterX, y: titleLabel.frame.midY)
  }
  
  override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
    super.setTitleColor(color, for: state)
    if state == .normal, let color = color {
      imageView?.tintColor = color
    }
  }
  
  func setTitleForLoadingState(_ title: String?) {
    self.titleForLoadingState = title
  }
  
}

// MARK: - Private Methods

private extension PrimaryButtonWithStyle {
  
  func removeSpinner() {
    imageView?.layer.transform = CATransform3DIdentity
    super.isEnabled = true
    title.map { setTitle($0, for: .normal) }
    title = nil
    spinner?.removeFromSuperview()
    spinner = nil
  }
  
  func addSpinner() {
    guard self.spinner == nil else { return }
    imageView?.layer.transform = CATransform3DMakeScale(0, 0, 0)
    super.isEnabled = false
    let spinner = UIActivityIndicatorView(style: .medium)
    spinner.translatesAutoresizingMaskIntoConstraints = false
    spinner.startAnimating()
    self.spinner = spinner
    addSubview(spinner)
    title = title(for: .normal)
    setTitle(titleForLoadingState ?? title, for: .normal)
  }
  
}
