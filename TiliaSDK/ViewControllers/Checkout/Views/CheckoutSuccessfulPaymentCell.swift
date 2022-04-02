//
//  CheckoutSuccessfulPaymentCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 02.04.2022.
//

import UIKit

final class CheckoutSuccessfulPaymentCell: UITableViewCell {
  
  private let iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .successIcon
    imageView.setContentHuggingPriority(.required, for: .horizontal)
    return imageView
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 16)
    label.textColor = .white
    label.text = L.success
    return label
  }()
  
  private let messageLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 16)
    label.textColor = .white
    label.numberOfLines = 0
    label.text = L.paymentProcessed
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Private Methods

private extension CheckoutSuccessfulPaymentCell {
  
  func setup() {
    let labelsStackView = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
    labelsStackView.spacing = 5
    labelsStackView.axis = .vertical
    
    let stackView = UIStackView(arrangedSubviews: [iconImageView, labelsStackView])
    stackView.alignment = .center
    stackView.spacing = 16
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    let backgroundView = UIView()
    backgroundView.clipsToBounds = true
    backgroundView.layer.cornerRadius = 6
    backgroundView.backgroundColor = .successColor
    backgroundView.translatesAutoresizingMaskIntoConstraints = false
    backgroundView.addSubview(stackView)
    contentView.addSubview(backgroundView)
    
    NSLayoutConstraint.activate([
      backgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      backgroundView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      backgroundView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
      backgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
      stackView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 12),
      stackView.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -16),
      stackView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -12)
    ])
  }
  
}
