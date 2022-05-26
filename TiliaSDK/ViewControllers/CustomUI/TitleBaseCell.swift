//
//  TitleBaseCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 06.05.2022.
//

import UIKit

class TitleBaseCell: UITableViewCell {
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    return label
  }()
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [titleLabel])
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 8
    return stackView
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  final func configure(title: String?,
                       font: UIFont = .systemFont(ofSize: 16),
                       textColor: UIColor = .primaryTextColor) {
    titleLabel.text = title
    titleLabel.isHidden = title == nil
    titleLabel.font = font
    titleLabel.textColor = textColor
  }
  
  final func addChildView(_ view: UIView, spacing: CGFloat = 8) {
    stackView.addArrangedSubview(view)
    stackView.setCustomSpacing(spacing, after: view)
  }
  
}

// MARK: - Private Methods

private extension TitleBaseCell {
  
  func setup() {
    selectionStyle = .none
    backgroundColor = .backgroundColor
    contentView.backgroundColor = .backgroundColor
    contentView.addSubview(stackView)
    
    let bottomAnchor = stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
    bottomAnchor.priority = UILayoutPriority(999)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
      bottomAnchor
    ])
  }
  
}
