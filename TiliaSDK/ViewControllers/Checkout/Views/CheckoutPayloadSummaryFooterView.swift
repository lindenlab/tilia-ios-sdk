//
//  CheckoutPayloadSummaryFooterView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import UIKit

final class CheckoutPayloadSummaryFooterView: UITableViewHeaderFooterView {
  
  private let topDivider: DividerView = {
    let view = DividerView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .titleColor
    label.font = UIFont.systemFont(ofSize: 16)
    label.text = L.total
    label.setContentCompressionResistancePriority(UILayoutPriority(751), for: .vertical)
    return label
  }()
  
  private let amountLabel: UILabel = {
    let label = UILabel()
    label.textColor = .titleColor
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
  
  func configure(amount: String) {
    amountLabel.text = amount
  }
  
}

// MARK: - Private Methods

private extension CheckoutPayloadSummaryFooterView {
  
  func setup() {
    let stackView = UIStackView(arrangedSubviews: [titleLabel, amountLabel])
    stackView.alignment = .center
    stackView.spacing = 5
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.distribution = .equalSpacing
    
    contentView.backgroundColor = .clear
    contentView.addSubview(stackView)
    contentView.addSubview(topDivider)
    contentView.addSubview(bottomDivider)
    
    let topConstraint = stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16)
    topConstraint.priority = UILayoutPriority(999)
    NSLayoutConstraint.activate([
      topConstraint,
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
      stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
      topDivider.topAnchor.constraint(equalTo: contentView.topAnchor),
      topDivider.leftAnchor.constraint(equalTo: contentView.leftAnchor),
      topDivider.rightAnchor.constraint(equalTo: contentView.rightAnchor),
      bottomDivider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      bottomDivider.leftAnchor.constraint(equalTo: contentView.leftAnchor),
      bottomDivider.rightAnchor.constraint(equalTo: contentView.rightAnchor)
    ])
  }
  
}
