//
//  TransactionDetailsCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 22.08.2022.
//

import UIKit

final class TransactionDetailsCell: UITableViewCell {
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .primaryTextColor
    label.font = .systemFont(ofSize: 14, weight: .medium)
    return label
  }()
  
  private let subTitleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .tertiaryTextColor
    label.font = .systemFont(ofSize: 12)
    label.numberOfLines = 0
    return label
  }()
  
  private let valueImageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()
  
  private let valueLabel: UILabel = {
    let label = UILabel()
    label.textColor = .primaryTextColor
    label.font = .systemFont(ofSize: 14)
    return label
  }()
  
  private let divider: DividerView = {
    let divider = DividerView()
    divider.translatesAutoresizingMaskIntoConstraints = false
    return divider
  }()
  
  private lazy var stackView: UIStackView = {
    let valueStackView = UIStackView(arrangedSubviews: [valueImageView, valueLabel])
    valueStackView.alignment = .center
    valueStackView.spacing = 4
    
    let mainStackView = UIStackView(arrangedSubviews: [titleLabel, valueStackView])
    mainStackView.spacing = 4
    mainStackView.alignment = .center
    mainStackView.distribution = .equalCentering
    
    let rootStackView = UIStackView(arrangedSubviews: [mainStackView, subTitleLabel])
    rootStackView.spacing = 8
    rootStackView.axis = .vertical
    return rootStackView
  }()
  
  private lazy var leftStackConstraint = stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16)
  private lazy var leftDividerConstraint = divider.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16)
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(title: String, subTitle: String?) {
    titleLabel.text = title
    subTitleLabel.text = subTitle
    subTitleLabel.isHidden = subTitle == nil
  }
  
  func configure(value: String) {
    valueLabel.text = value
    valueLabel.attributedText = nil
  }
  
  func configure(value: NSAttributedString) {
    valueLabel.attributedText = value
    valueLabel.text = nil
  }
  
  func configure(image: UIImage?, color: UIColor) {
    valueImageView.image = image?.withRenderingMode(.alwaysTemplate)
    valueImageView.isHidden = image == nil
    valueImageView.tintColor = color
  }
  
  func configure(leftInset: CGFloat, isDividerHidden: Bool) {
    leftStackConstraint.constant = leftInset
    leftDividerConstraint.constant = leftInset
    divider.isHidden = isDividerHidden
  }
  
}

// MARK: - Private Methods

private extension TransactionDetailsCell {
  
  func setup() {
    selectionStyle = .none
    backgroundColor = .backgroundColor
    contentView.backgroundColor = .backgroundColor
    contentView.addSubview(stackView)
    contentView.addSubview(divider)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      leftStackConstraint,
      stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
      leftDividerConstraint,
      divider.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
      divider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
    ])
  }
  
}
