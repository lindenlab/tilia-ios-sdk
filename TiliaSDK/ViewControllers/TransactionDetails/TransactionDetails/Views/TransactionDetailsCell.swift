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
    label.setContentCompressionResistancePriority(.required, for: .horizontal)
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
    label.numberOfLines = 0
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
    
    let stackView = UIStackView(arrangedSubviews: [titleLabel, valueStackView])
    stackView.spacing = 10
    stackView.alignment = .center
    stackView.distribution = .equalCentering
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
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
  
  func configure(title: String,
                 value: String,
                 image: UIImage?,
                 color: UIColor?,
                 leftInset: CGFloat,
                 isDividerHidden: Bool) {
    titleLabel.text = title
    valueLabel.text = value
    valueImageView.image = image?.withRenderingMode(.alwaysTemplate)
    valueImageView.isHidden = image == nil
    valueImageView.tintColor = color
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
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
      leftStackConstraint,
      stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
      leftDividerConstraint,
      divider.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
      divider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])
  }
  
}
