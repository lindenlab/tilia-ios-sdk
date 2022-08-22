//
//  TransactionDetailsTitleHeaderView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 22.08.2022.
//

import UIKit

final class TransactionDetailsTitleHeaderView: UITableViewHeaderFooterView {
  
  private let label: UILabel = {
    let label = UILabel()
    label.textColor = .primaryTextColor
    label.font = .systemFont(ofSize: 14, weight: .semibold)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(title: String) {
    label.text = title
  }
  
}

// MARK: - Private Methods

private extension TransactionDetailsTitleHeaderView {
  
  func setup() {
    contentView.backgroundColor = .backgroundColor
    contentView.addSubview(label)
    
    let topConstraint = label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32)
    topConstraint.priority = UILayoutPriority(999)
    NSLayoutConstraint.activate([
      topConstraint,
      label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
      label.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 32),
      label.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
    ])
  }
  
}
