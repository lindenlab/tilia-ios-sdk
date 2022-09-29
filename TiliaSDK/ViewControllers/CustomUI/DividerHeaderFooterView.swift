//
//  DividerHeaderFooterView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 29.09.2022.
//

import UIKit

final class DividerHeaderFooterView: UITableViewHeaderFooterView {
  
  private let divider: DividerView = {
    let view = DividerView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private lazy var topConstraint: NSLayoutConstraint = {
    let constraint = divider.topAnchor.constraint(equalTo: contentView.topAnchor)
    constraint.priority = UILayoutPriority(999)
    return constraint
  }()
  
  private lazy var bottomConstraint = divider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
  
  private lazy var leftConstraint = divider.leftAnchor.constraint(equalTo: contentView.leftAnchor)
  
  private lazy var rightConstraint = divider.rightAnchor.constraint(equalTo: contentView.rightAnchor)
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(insets: UIEdgeInsets) {
    topConstraint.constant = insets.top
    bottomConstraint.constant = -insets.bottom
    leftConstraint.constant = insets.left
    rightConstraint.constant = -insets.right
  }
  
}

// MARK: - Private Methods

private extension DividerHeaderFooterView {
  
  func setup() {
    contentView.backgroundColor = .backgroundColor
    contentView.addSubview(divider)
    
    NSLayoutConstraint.activate([
      topConstraint,
      bottomConstraint,
      leftConstraint,
      rightConstraint
    ])
  }
  
}
