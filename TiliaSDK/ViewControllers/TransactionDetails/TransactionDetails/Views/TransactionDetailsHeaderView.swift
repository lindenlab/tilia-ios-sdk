//
//  TransactionDetailsHeaderView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 22.08.2022.
//

import UIKit

final class TransactionDetailsHeaderView: UITableViewHeaderFooterView {
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    return label
  }()
  
  private let subTitleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .tertiaryTextColor
    label.numberOfLines = 0
    label.font = .systemFont(ofSize: 14)
    return label
  }()
  
  private let statusImageView: UIImageView = {
    let imageView = UIImageView()
    return imageView
  }()
  
  private let statusTitleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .primaryTextColor
    label.font = .boldSystemFont(ofSize: 14)
    return label
  }()
  
  private let statusValueLabel: UILabel = {
    let label = UILabel()
    label.textColor = .primaryTextColor
    label.font = .systemFont(ofSize: 14)
    return label
  }()
  
  private lazy var statusInfoStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [statusTitleLabel,
                                                   statusImageView,
                                                   statusValueLabel])
    stackView.alignment = .center
    stackView.spacing = 4
    stackView.setCustomSpacing(6, after: statusTitleLabel)
    return stackView
  }()
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(image: UIImage?,
                 title: NSAttributedString,
                 subTitle: String) {
    imageView.image = image
    titleLabel.attributedText = title
    subTitleLabel.text = subTitle
  }
  
  func configure(statusImage: UIImage?,
                 statusTitle: String?,
                 statusSubTitle: String?) {
    statusInfoStackView.isHidden = statusImage == nil && statusTitle == nil
    statusImageView.image = statusImage
    statusTitleLabel.text = statusTitle
  }
  
}

// MARK: - Private Methods

private extension TransactionDetailsHeaderView {
  
  func setup() {
    let mainStackView = UIStackView(arrangedSubviews: [imageView,
                                                       titleLabel,
                                                       subTitleLabel,
                                                       statusInfoStackView])
    mainStackView.axis = .vertical
    mainStackView.alignment = .center
    mainStackView.spacing = 4
    mainStackView.setCustomSpacing(16, after: subTitleLabel)
    
    let rootStackView = UIStackView(arrangedSubviews: [mainStackView]) // TODO: - Add here error view
    rootStackView.spacing = 16
    rootStackView.axis = .vertical
    rootStackView.translatesAutoresizingMaskIntoConstraints = false
    
    contentView.backgroundColor = .backgroundColor
    contentView.addSubview(rootStackView)
    
    let topConstraint = rootStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32)
    topConstraint.priority = UILayoutPriority(999)
    NSLayoutConstraint.activate([
      topConstraint,
      rootStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -64),
      rootStackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      rootStackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
    ])
  }
  
}
