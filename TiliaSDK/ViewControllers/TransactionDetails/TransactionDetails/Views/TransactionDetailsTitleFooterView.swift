//
//  TransactionDetailsTitleFooterView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.08.2022.
//

import UIKit

final class TransactionDetailsTitleFooterView: UITableViewHeaderFooterView {
  
  private let divider: DividerView = {
    let view = DividerView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .primaryTextColor
    label.font = .systemFont(ofSize: 16, weight: .semibold)
    return label
  }()
  
  private let valueLabel: UILabel = {
    let label = UILabel()
    label.textColor = .primaryTextColor
    label.font = .systemFont(ofSize: 16, weight: .semibold)
    return label
  }()
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(title: String?, value: String?) {
    titleLabel.text = title
    valueLabel.text = value
  }
  
}

// MARK: - Private Methods

private extension TransactionDetailsTitleFooterView {
  
  func setup() {
    let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
    stackView.spacing = 4
    stackView.distribution = .equalCentering
    stackView.alignment = .center
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.backgroundColor = .backgroundColor
    contentView.addSubview(stackView)
    contentView.addSubview(divider)
    
    let topConstraint = stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16)
    topConstraint.priority = UILayoutPriority(999)
    NSLayoutConstraint.activate([
      topConstraint,
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
      stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
      divider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      divider.leftAnchor.constraint(equalTo: contentView.leftAnchor),
      divider.rightAnchor.constraint(equalTo: contentView.rightAnchor)
    ])
  }
  
}
