//
//  TransactionHistoryCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 29.09.2022.
//

import UIKit

final class TransactionHistoryCell: UITableViewCell {
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 14)
    label.textColor = .primaryTextColor
    return label
  }()
  
  private let subTitleLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 12)
    label.textColor = .tertiaryTextColor
    return label
  }()
  
  private let valueLabel: UILabel = {
    let label = UILabel()
    label.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
    return label
  }()
  
  private let subValueImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.tintColor = .failureBackgroundColor
    return imageView
  }()
  
  private let subValueLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 12)
    label.textColor = .tertiaryTextColor
    return label
  }()
  
  private lazy var subValueStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [subValueImageView, subValueLabel])
    stackView.spacing = 6
    stackView.alignment = .center
    return stackView
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
                 subTitle: String,
                 value: NSAttributedString,
                 subValueImage: UIImage?,
                 subValueTitle: String?,
                 isDividerHidden: Bool) {
    titleLabel.text = title
    subTitleLabel.text = subTitle
    valueLabel.attributedText = value
    subValueImageView.image = subValueImage
    subValueLabel.text = subValueTitle
    subValueStackView.isHidden = subValueImage == nil && subValueTitle == nil
    divider.isHidden = isDividerHidden
  }
  
}

// MARK: - Private Methods

private extension TransactionHistoryCell {
  
  func setup() {
    let leadingStackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
    leadingStackView.axis = .vertical
    leadingStackView.spacing = 4
    leadingStackView.alignment = .leading
    
    let trailingStackView = UIStackView(arrangedSubviews: [valueLabel, subValueStackView])
    trailingStackView.axis = .vertical
    trailingStackView.spacing = 4
    trailingStackView.alignment = .trailing
    
    let stackView = UIStackView(arrangedSubviews: [leadingStackView, trailingStackView])
    stackView.spacing = 4
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.distribution = .equalCentering
    stackView.alignment = .center
    
    isExclusiveTouch = true
    backgroundColor = .clear
    contentView.backgroundColor = .clear
    contentView.addSubview(stackView)
    contentView.addSubview(divider)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
      stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
      divider.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      divider.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
      divider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])
  }
  
}
