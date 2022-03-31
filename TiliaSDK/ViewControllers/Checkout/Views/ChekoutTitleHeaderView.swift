//
//  ChekoutTitleHeaderView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import UIKit

final class ChekoutTitleHeaderView: UITableViewHeaderFooterView {
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .customBlack
    label.font = UIFont.boldSystemFont(ofSize: 20)
    return label
  }()
  
  private let subTitleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .grayWithDarkTransparency
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }()
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
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
  
}

// MARK: - Private Methods

private extension ChekoutTitleHeaderView {
  
  func setup() {
    let stackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(stackView)
    
    let topConstraint = stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16)
    topConstraint.priority = UILayoutPriority(999)
    NSLayoutConstraint.activate([
      topConstraint,
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
      stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
    ])
  }
  
}
