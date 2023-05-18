//
//  PrimaryButton.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 28.03.2022.
//

import UIKit

final class PrimaryButton: Button {
  
  override var intrinsicContentSize: CGSize {
    return CGSize(width: super.intrinsicContentSize.width, height: 44)
  }
  
  var isLoading: Bool = false {
    didSet {
      if isLoading {
        spinner?.startAnimating()
      }
      isLoading ? addSpinner() : removeSpinner()
    }
  }
  
  override var isEnabled: Bool {
    get {
      return isLoading ? false : super.isEnabled
    }
    set {
      guard !isLoading else { return }
      super.isEnabled = newValue
    }
  }
  
  private var titleForLoadingState: String?
  private var title: String?
  private var spinner: UIActivityIndicatorView?
  
  override init(style: Button.Style? = nil, frame: CGRect = .zero) {
    super.init(style: style, frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    guard let spinner = spinner, let titleLabel = titleLabel else { return }
    let spinnerCenterX: CGFloat
    switch style {
    case .titleAndImageCenter, .none:
      spinnerCenterX = titleLabel.frame.maxX + 15
    case .imageAndTitleCenter:
      spinnerCenterX = titleLabel.frame.minX - 15
    }
    spinner.center = CGPoint(x: spinnerCenterX, y: titleLabel.frame.midY)
  }
  
  func setTitleForLoadingState(_ title: String?) {
    self.titleForLoadingState = title
  }
  
}

// MARK: - Private Methods

private extension PrimaryButton {
  
  func setup() {
    setTitleColor(.primaryButtonTextColor, for: .normal)
    setBackgroundColor(.primaryColor, for: .normal)
    setBackgroundColor(.primaryColor.withAlphaComponent(0.5), for: .disabled)
    setBackgroundColor(.primaryColor.withAlphaComponent(0.5), for: .highlighted)
    layer.cornerRadius = 6
    titleLabel?.font = .boldSystemFont(ofSize: 16)
  }
  
  func removeSpinner() {
    guard let spinner = self.spinner else { return }
    imageView?.layer.transform = CATransform3DIdentity
    super.isEnabled = true
    title.map { setTitle($0, for: .normal) }
    title = nil
    spinner.removeFromSuperview()
    self.spinner = nil
    switch style {
    case .titleAndImageCenter, .none:
      contentEdgeInsets.right -= spinner.frame.width
    case .imageAndTitleCenter:
      contentEdgeInsets.left -= spinner.frame.width
    }
  }
  
  func addSpinner() {
    guard self.spinner == nil else { return }
    imageView?.layer.transform = CATransform3DMakeScale(0, 0, 0)
    super.isEnabled = false
    let spinner = UIActivityIndicatorView(style: .medium)
    titleColor(for: state).map { spinner.color = $0 }
    spinner.startAnimating()
    self.spinner = spinner
    addSubview(spinner)
    title = title(for: .normal)
    setTitle(titleForLoadingState ?? title, for: .normal)
    switch style {
    case .titleAndImageCenter, .none:
      contentEdgeInsets.right += spinner.frame.width
    case .imageAndTitleCenter:
      contentEdgeInsets.left += spinner.frame.width
    }
  }
  
}
