//
//  UserInfoHeaderView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 04.05.2022.
//

import UIKit

protocol UserInfoHeaderViewDelegate: AnyObject {
  func userInfoHeaderView(_ header: UserInfoHeaderView, willExpand isExpanded: Bool)
}

final class UserInfoHeaderView: UITableViewHeaderFooterView {
  
  enum Mode {
    
    case normal
    case expanded
    case passed
    case failed
    case disabled
    
  }
  
  private weak var delegate: UserInfoHeaderViewDelegate?
  private lazy var isExpanded = mode.isExpanded
  private var mode: Mode = .normal
  
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
    imageView.contentMode = .center
    return imageView
  }()
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setup()
    setupMode(animated: false)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(title: String?,
                 delegate: UserInfoHeaderViewDelegate?) {
    titleLabel.text = title
    self.delegate = delegate
  }
  
  func configure(mode: Mode, animated: Bool) {
    self.mode = mode
    setupMode(animated: animated)
  }
  
}

// MARK: - Private Methods

private extension UserInfoHeaderView {
  
  func setup() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
    contentView.addGestureRecognizer(tap)
    
    let stackView = UIStackView(arrangedSubviews: [titleLabel, imageView])
    stackView.alignment = .center
    stackView.spacing = 5
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.distribution = .equalSpacing
    
    contentView.addSubview(stackView)
    contentView.addSubview(divider)
    
    let topConstraint = stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16)
    topConstraint.priority = UILayoutPriority(999)
    
    let rightConstraint = stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
    rightConstraint.priority = UILayoutPriority(999)
    
    NSLayoutConstraint.activate([
      topConstraint,
      rightConstraint,
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
      stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      divider.topAnchor.constraint(equalTo: topAnchor),
      divider.leftAnchor.constraint(equalTo: leftAnchor),
      divider.rightAnchor.constraint(equalTo: rightAnchor),
      imageView.widthAnchor.constraint(equalToConstant: 24),
      imageView.heightAnchor.constraint(equalToConstant: 24)
    ])
  }
  
  func setupMode(animated: Bool) {
    isUserInteractionEnabled = mode.isEnabled
    isExpanded = mode.isExpanded
    divider.isHidden = mode.isDividerHidden
    titleLabel.textColor = mode.titleColor
    imageView.image = mode.icon
    imageView.tintColor = mode.iconColor
    imageView.transform = .identity
    if isExpanded {
      imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
    }
    UIView.animate(withDuration: animated ? 0.3 : 0) {
      self.contentView.backgroundColor = self.mode.backgroundColor
    }
  }
  
  @objc func didTap() {
    delegate?.userInfoHeaderView(self, willExpand: !isExpanded)
  }
  
}

private extension UserInfoHeaderView.Mode {
  
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
  
  var icon: UIImage? {
    let image: UIImage?
    switch self {
    case .normal, .expanded, .disabled: image = .bottomArrowIcon
    case .passed: image = .successIcon
    case .failed: image = .failureIcon
    }
    return image?.withRenderingMode(.alwaysTemplate)
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
  
  var isExpanded: Bool {
    switch self {
    case .expanded: return true
    default: return false
    }
  }
  
  var isEnabled: Bool {
    switch self {
    case .disabled: return false
    default: return true
    }
  }
  
}
