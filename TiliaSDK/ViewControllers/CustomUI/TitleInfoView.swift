//
//  TitleInfoView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 02.05.2022.
//

import UIKit

final class TitleInfoView: UIView {
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .primaryTextColor
    label.font = UIFont.boldSystemFont(ofSize: 20)
    return label
  }()
  
  private let subTitleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .primaryTextColor
    label.font = UIFont.systemFont(ofSize: 16)
    label.numberOfLines = 0
    return label
  }()
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
    stackView.axis = .vertical
    stackView.spacing = 8
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  var title: String? {
    get {
      return titleLabel.text
    }
    set {
      titleLabel.text = newValue
    }
  }
  
  var subTitle: String? {
    get {
      return subTitleLabel.text
    }
    set {
      subTitleLabel.text = newValue
      subTitleLabel.isHidden = newValue == nil
    }
  }
  
  var subTitleTextColor: UIColor! {
    get {
      return subTitleLabel.textColor
    }
    set {
      subTitleLabel.textColor = newValue
    }
  }
  
  var subTitleTextFont: UIFont! {
    get {
      return subTitleLabel.font
    }
    set {
      subTitleLabel.font = newValue
    }
  }
  
  var spacing: CGFloat {
    get {
      return stackView.spacing
    }
    set {
      stackView.spacing = newValue
    }
  }
  
  init(frame: CGRect = .zero, insets: UIEdgeInsets = .zero) {
    super.init(frame: frame)
    setup(insets: insets)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Private Methods

private extension TitleInfoView {
  
  func setup(insets: UIEdgeInsets) {
    backgroundColor = .clear
    addSubview(stackView)
    
    let topConstraint = stackView.topAnchor.constraint(equalTo: topAnchor, constant: insets.top)
    topConstraint.priority = UILayoutPriority(999)
    
    let leftConstraint = stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: insets.left)
    leftConstraint.priority = UILayoutPriority(999)
    
    NSLayoutConstraint.activate([
      topConstraint,
      leftConstraint,
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom),
      stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -insets.right)
    ])
  }
  
}
