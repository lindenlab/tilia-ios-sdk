//
//  TransactionHistoryHeaderView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 29.09.2022.
//

import UIKit

final class TransactionHistoryHeaderView: UITableViewHeaderFooterView {
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .secondaryTextColor
    label.font = .boldSystemFont(ofSize: 12)
    return label
  }()
  
  private let valueLabel: UILabel = {
    let label = UILabel()
    label.textColor = .tertiaryTextColor
    label.font = .systemFont(ofSize: 12)
    return label
  }()
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(title: String, value: NSAttributedString?) {
    titleLabel.text = title
    valueLabel.attributedText = value
  }
  
}

// MARK: - Private Methods

private extension TransactionHistoryHeaderView {
  
  func setup() {
    let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
    stackView.alignment = .center
    stackView.spacing = 4
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.backgroundColor = .backgroundColor
    contentView.addSubview(stackView)
    
    let topConstraint = stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20)
    topConstraint.priority = UILayoutPriority(999)
    NSLayoutConstraint.activate([
      topConstraint,
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
      stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
    ])
  }
  
}
