//
//  SelectableView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 04.05.2022.
//

import UIKit

final class SelectableView: UIControl {
  
  enum Mode {
    
    case normal
    case expanded
    case passed
    case failed
    case disabled
    
  }
  
  private let divider: DividerView = {
    let view = DividerView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 16)
    return label
  }()
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()
  
  var mode: Mode = .normal {
    didSet {
      setupMode()
    }
  }
  
  var title: String? {
    get {
      return titleLabel.text
    }
    set {
      titleLabel.text = newValue
    }
  }
  
  override var isSelected: Bool {
    get {
      return super.isSelected
    }
    set {
      super.isSelected.toggle()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    setupMode()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Private Methods

private extension SelectableView {
  
  func setup() {
    let stackView = UIStackView(arrangedSubviews: [titleLabel, imageView])
    stackView.alignment = .center
    stackView.spacing = 5
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.distribution = .equalSpacing
    
    isExclusiveTouch = true
    addTarget(self, action: #selector(didTap), for: .touchUpInside)
    addSubview(stackView)
    addSubview(divider)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
      stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
      divider.topAnchor.constraint(equalTo: topAnchor),
      divider.leftAnchor.constraint(equalTo: leftAnchor),
      divider.rightAnchor.constraint(equalTo: rightAnchor)
    ])
  }
  
  func setupMode() {
    
  }
  
  @objc func didTap() {
    
  }
  
}

private extension SelectableView.Mode {
  
  var backgroundColor: UIColor {
    switch self {
    case .expanded: return .primaryColor
    default: return .clear
    }
  }
  
  var isDividerHidden: Bool {
    switch self {
    case .expanded: return true
    default: return false
    }
  }
  
  var titleColor: UIColor {
    switch self {
    case .normal, .passed: return .primaryTextColor
    case .expanded: return .primaryButtonTextColor
    case .failed: return .failureBackgroundColor
    case .disabled: return .tertiaryTextColor
    }
  }
  
  var iconColor: UIColor {
    switch self {
    case .normal: return .primaryTextColor
    case .expanded: return .primaryButtonTextColor
    case .passed: return .successBackgroundColor
    case .failed: return .failureBackgroundColor
    case .disabled: return .tertiaryTextColor
    }
  }
  
}
