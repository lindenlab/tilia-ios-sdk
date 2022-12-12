//
//  CheckoutPaymentMethodSwitchCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 21.11.2022.
//

import UIKit

protocol CheckoutPaymentMethodSwitchCellDelegate: AnyObject {
  func checkoutPaymentMethodSwitchCell(_ cell: CheckoutPaymentMethodSwitchCell, didSelect isOn: Bool)
}

final class CheckoutPaymentMethodSwitchCell: UITableViewCell {
  
  private weak var delegate: CheckoutPaymentMethodSwitchCellDelegate?
  
  private let iconImageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .primaryTextColor
    label.font = .systemFont(ofSize: 14)
    label.setContentCompressionResistancePriority(.init(749), for: .horizontal)
    label.setContentHuggingPriority(.init(249), for: .horizontal)
    label.textAlignment = .right
    return label
  }()
  
  private let uiSwitch: Switch = {
    let uiSwitch = Switch()
    return uiSwitch
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(image: UIImage?,
                 title: String,
                 delegate: CheckoutPaymentMethodSwitchCellDelegate?) {
    iconImageView.image = image
    titleLabel.text = title
    self.delegate = delegate
  }
  
  func configure(isOn: Bool) {
    uiSwitch.isOn = isOn
  }
  
  func configure(isEnabled: Bool) {
    uiSwitch.isEnabled = isEnabled
  }
  
}

private extension CheckoutPaymentMethodSwitchCell {
  
  func setup() {
    uiSwitch.addTarget(self, action: #selector(switchDidChange), for: .valueChanged)
    
    selectionStyle = .none
    backgroundColor = .backgroundColor
    contentView.clipsToBounds = true
    contentView.backgroundColor = .backgroundDarkerColor
    contentView.layer.cornerRadius = 10
    
    let stackView = UIStackView(arrangedSubviews: [iconImageView,
                                                   titleLabel,
                                                   uiSwitch])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 8
    stackView.alignment = .center
    
    contentView.addSubview(stackView)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
    ])
  }
  
  @objc func switchDidChange() {
    delegate?.checkoutPaymentMethodSwitchCell(self, didSelect: uiSwitch.isOn)
  }
  
}
