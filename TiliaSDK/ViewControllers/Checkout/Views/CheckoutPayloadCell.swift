//
//  CheckoutPayloadCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import UIKit

final class CheckoutPayloadCell: UITableViewCell {
  
  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.textColor = .titleColor
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()
  
  private let productLabel: UILabel = {
    let label = UILabel()
    label.textColor = .subTitleColor2
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()
  
  private let amountLabel: UILabel = {
    let label = UILabel()
    label.textColor = .titleColor
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()
  
  private let divider: DividerView = {
    let view = DividerView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(description: String, product: String, amount: String, isDividerHidden: Bool) {
    descriptionLabel.text = description
    productLabel.text = product
    amountLabel.text = amount
    divider.isHidden = isDividerHidden
  }
  
}

// MARK: - Private Methods

private extension CheckoutPayloadCell {
  
  func setup() {
    selectionStyle = .none
    
    let leadingStackView = UIStackView(arrangedSubviews: [descriptionLabel, productLabel])
    leadingStackView.spacing = 2
    leadingStackView.axis = .vertical
    
    let stackView = UIStackView(arrangedSubviews: [leadingStackView, amountLabel])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 5
    stackView.distribution = .equalSpacing
    stackView.alignment = .top
    
    backgroundColor = .clear
    contentView.backgroundColor = .clear
    contentView.addSubview(stackView)
    contentView.addSubview(divider)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
      stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
      divider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      divider.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      divider.rightAnchor.constraint(equalTo: contentView.rightAnchor)
    ])
  }
  
}
