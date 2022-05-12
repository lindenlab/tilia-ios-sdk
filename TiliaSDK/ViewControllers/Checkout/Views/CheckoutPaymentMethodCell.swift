//
//  CheckoutPaymentMethodCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 01.04.2022.
//

import UIKit

final class CheckoutPaymentMethodCell: UITableViewCell {
  
  private let radioButton: RadioButton = {
    let button = RadioButton()
    button.isUserInteractionEnabled = false
    return button
  }()
  
  private let iconImageView: UIImageView = {
    let imageView = UIImageView(image: .walletIcon)
    return imageView
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .primaryTextColor
    label.font = UIFont.systemFont(ofSize: 16)
    return label
  }()
  
  private let subTitleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .secondaryTextColor
    label.font = UIFont.systemFont(ofSize: 12)
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(title: String, subTitle: String, isSelected: Bool) {
    titleLabel.text = title
    subTitleLabel.text = subTitle
    radioButton.setSelected(isSelected)
  }
  
}

// MARK: - Private Methods

private extension CheckoutPaymentMethodCell {
  
  func setup() {
    selectionStyle = .none
    let leadingStackView = UIStackView(arrangedSubviews: [radioButton, iconImageView])
    leadingStackView.alignment = .center
    leadingStackView.spacing = 16

    let trailingStackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
    trailingStackView.spacing = 2
    trailingStackView.alignment = .trailing
    trailingStackView.axis = .vertical
    
    
    let stackView = UIStackView(arrangedSubviews: [leadingStackView, trailingStackView])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 5
    stackView.distribution = .equalSpacing
    stackView.alignment = .center
    
    backgroundColor = .clear
    contentView.backgroundColor = .clear
    contentView.addSubview(stackView)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
    ])
  }
  
}