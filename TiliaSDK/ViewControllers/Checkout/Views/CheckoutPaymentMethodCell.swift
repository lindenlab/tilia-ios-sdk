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
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .titleColor
    label.font = UIFont.systemFont(ofSize: 16)
    return label
  }()
  
  private let subTitleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .subTitleColor2
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
    let leadingStackView = UIStackView(arrangedSubviews: [radioButton])
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
    contentView.addSubview(stackView)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
    ])
  }
  
}
