//
//  CheckoutPaymentMethodRadioCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 01.04.2022.
//

import UIKit

protocol CheckoutPaymentMethodRadioCellDelegate: AnyObject {
  func checkoutPaymentMethodRadioCellDidSelect(_ cell: CheckoutPaymentMethodRadioCell)
}

final class CheckoutPaymentMethodRadioCell: UITableViewCell {
  
  private weak var delegate: CheckoutPaymentMethodRadioCellDelegate?
  
  private let radioButton: RadioButton = {
    let button = RadioButton()
    button.accessibilityIdentifier = "choosePaymentMethodButton"
    return button
  }()
  
  private let iconImageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .primaryTextColor
    label.font = .systemFont(ofSize: 16)
    label.setContentCompressionResistancePriority(.init(749), for: .horizontal)
    label.setContentHuggingPriority(.init(249), for: .horizontal)
    label.textAlignment = .right
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
  
  func configure(title: String,
                 isDividerHidden: Bool,
                 icon: UIImage?,
                 delegate: CheckoutPaymentMethodRadioCellDelegate?) {
    titleLabel.text = title
    self.delegate = delegate
    divider.isHidden = isDividerHidden
    iconImageView.image = icon
  }
  
  func configure(isSelected: Bool) {
    radioButton.isRadioSelected = isSelected
  }
  
  func configure(isEnabled: Bool) {
    radioButton.isEnabled = isEnabled
  }
  
}

// MARK: - Private Methods

private extension CheckoutPaymentMethodRadioCell {
  
  func setup() {
    radioButton.addTarget(self, action: #selector(radioButtonDidTap), for: .touchUpInside)
    
    selectionStyle = .none
    accessibilityIdentifier = "checkoutPaymentMethodCell"
    
    let stackView = UIStackView(arrangedSubviews: [radioButton,
                                                   iconImageView,
                                                   titleLabel])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 5
    stackView.alignment = .center
    stackView.setCustomSpacing(16, after: radioButton)
    
    backgroundColor = .backgroundColor
    contentView.backgroundColor = .backgroundColor
    contentView.addSubview(stackView)
    contentView.addSubview(divider)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
      divider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      divider.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      divider.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
    ])
  }
  
  @objc func radioButtonDidTap() {
    delegate?.checkoutPaymentMethodRadioCellDidSelect(self)
  }
  
}
