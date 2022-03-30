//
//  CheckoutPayloadFooterView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import UIKit

final class CheckoutPayloadFooterView: UITableViewHeaderFooterView {
  
  private let topDivider: DividerView = {
    let view = DividerView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .customBlack
    label.font = UIFont.systemFont(ofSize: 16)
    return label
  }()
  
  private let amountLabel: UILabel = {
    let label = UILabel()
    label.textColor = .customBlack
    label.font = UIFont.systemFont(ofSize: 16)
    return label
  }()
  
  private let bottomDivider: DividerView = {
    let view = DividerView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(title: String, amount: String) {
    titleLabel.text = title
    amountLabel.text = amount
  }
  
}

// MARK: - Private Methods

private extension CheckoutPayloadFooterView {
  
  func setup() {
    let stackView = UIStackView(arrangedSubviews: [titleLabel, amountLabel])
    stackView.alignment = .center
    stackView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(stackView)
    contentView.addSubview(topDivider)
    contentView.addSubview(bottomDivider)
    let topConstraint = stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16)
    topConstraint.priority = UILayoutPriority(999)
    NSLayoutConstraint.activate([
      topConstraint,
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      topDivider.topAnchor.constraint(equalTo: contentView.topAnchor),
      topDivider.leftAnchor.constraint(equalTo: contentView.leftAnchor),
      topDivider.rightAnchor.constraint(equalTo: contentView.rightAnchor),
      bottomDivider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      bottomDivider.leftAnchor.constraint(equalTo: contentView.leftAnchor),
      bottomDivider.rightAnchor.constraint(equalTo: contentView.rightAnchor)
    ])
  }
  
}
