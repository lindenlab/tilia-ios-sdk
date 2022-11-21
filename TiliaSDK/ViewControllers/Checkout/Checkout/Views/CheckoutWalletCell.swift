//
//  CheckoutWalletCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 21.11.2022.
//

import UIKit

protocol CheckoutWalletCellDelegate: AnyObject {
  func checkoutWalletCell(_ cell: CheckoutWalletCell, didSelectIsWalletOn isOn: Bool)
}

final class CheckoutWalletCell: UITableViewCell {
  
  private weak var delegate: CheckoutWalletCellDelegate?
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .primaryTextColor
    label.text = "Here will be text"
    label.font = UIFont.systemFont(ofSize: 16)
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
  
  func configure(value: String,
                 isOn: Bool,
                 isDividerHidden: Bool,
                 delegate: CheckoutWalletCellDelegate?) {
    uiSwitch.isOn = isOn
    divider.isHidden = isDividerHidden
    self.delegate = delegate
  }
  
}

private extension CheckoutWalletCell {
  
  func setup() {
    uiSwitch.addTarget(self, action: #selector(switchDidChange), for: .valueChanged)
    
    selectionStyle = .none
    backgroundColor = .backgroundColor
    contentView.backgroundColor = .backgroundColor
    
    let stackView = UIStackView(arrangedSubviews: [titleLabel, uiSwitch])
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
    delegate?.checkoutWalletCell(self, didSelectIsWalletOn: uiSwitch.isOn)
  }
  
}
