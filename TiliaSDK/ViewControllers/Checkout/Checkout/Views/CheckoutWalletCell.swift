//
//  CheckoutWalletCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 21.11.2022.
//

import UIKit

protocol CheckoutWalletCellDelegate: AnyObject {
  func checkoutWalletCell(_ cell: CheckoutWalletCell, didSelect isOn: Bool)
}

final class CheckoutWalletCell: UITableViewCell {
  
  private weak var delegate: CheckoutWalletCellDelegate?
  
  private let iconImageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .primaryTextColor
    label.font = .systemFont(ofSize: 16)
    label.setContentCompressionResistancePriority(.init(749), for: .horizontal)
    return label
  }()
  
  private let uiSwitch: Switch = {
    let uiSwitch = Switch()
    return uiSwitch
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
  
  func configure(image: UIImage?,
                 title: String,
                 isDividerHidden: Bool,
                 delegate: CheckoutWalletCellDelegate?) {
    iconImageView.image = image
    titleLabel.text = title
    divider.isHidden = isDividerHidden
    self.delegate = delegate
  }
  
  func configure(isOn: Bool) {
    uiSwitch.isOn = isOn
  }
  
  func configure(isEnabled: Bool) {
    uiSwitch.isEnabled = isEnabled
  }
  
}

private extension CheckoutWalletCell {
  
  func setup() {
    uiSwitch.addTarget(self, action: #selector(switchDidChange), for: .valueChanged)
    
    selectionStyle = .none
    backgroundColor = .backgroundColor
    contentView.backgroundColor = .backgroundColor
    
    let leadingStackView = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
    leadingStackView.alignment = .center
    leadingStackView.spacing = 8
    
    let stackView = UIStackView(arrangedSubviews: [leadingStackView, uiSwitch])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 5
    stackView.distribution = .equalSpacing
    stackView.alignment = .center
    
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
  
  @objc func switchDidChange() {
    delegate?.checkoutWalletCell(self, didSelect: uiSwitch.isOn)
  }
  
}
