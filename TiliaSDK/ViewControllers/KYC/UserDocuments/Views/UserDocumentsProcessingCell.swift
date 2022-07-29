//
//  UserDocumentsProcessingCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 08.07.2022.
//

import UIKit

final class UserDocumentsProcessingCell: UITableViewCell {
  
  private let spinner: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .large)
    view.startAnimating()
    return view
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 16)
    label.textColor = .primaryTextColor
    label.numberOfLines = 0
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(title: String) {
    titleLabel.text = title
    spinner.startAnimating()
  }
  
}

// MARK: - Private Methods

private extension UserDocumentsProcessingCell {
  
  func setup() {
    selectionStyle = .none
    backgroundColor = .backgroundColor
    contentView.backgroundColor = .backgroundColor
    
    let stackView = UIStackView(arrangedSubviews: [spinner, titleLabel])
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.alignment = .center
    stackView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
      stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
    ])
  }
  
}
