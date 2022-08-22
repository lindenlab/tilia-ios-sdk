//
//  ToastView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 08.04.2022.
//

import UIKit

final class ToastView: UIView {
  
  private let iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.setContentHuggingPriority(.required, for: .horizontal)
    return imageView
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .boldSystemFont(ofSize: 16)
    return label
  }()
  
  private let messageLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 16)
    label.numberOfLines = 0
    return label
  }()
  
  init(frame: CGRect = .zero, isSuccess: Bool) {
    super.init(frame: frame)
    setup()
    setupColors(isSuccess: isSuccess)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(title: String, message: String) {
    titleLabel.text = title
    messageLabel.text = message
  }
  
}

// MARK: - Private Methods

private extension ToastView {
  
  func setup() {
    clipsToBounds = true
    layer.cornerRadius = 6
    
    let labelsStackView = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
    labelsStackView.spacing = 5
    labelsStackView.axis = .vertical
    
    let stackView = UIStackView(arrangedSubviews: [iconImageView, labelsStackView])
    stackView.alignment = .center
    stackView.spacing = 16
    stackView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(stackView)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
      stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
    ])
  }
  
  func setupColors(isSuccess: Bool) {
    let primaryColor: UIColor = isSuccess ? .successPrimaryColor : .failurePrimaryColor
    let image: UIImage? = isSuccess ? .successIcon : .failureIcon
    backgroundColor = isSuccess ? .successBackgroundColor : .failureBackgroundColor
    iconImageView.image = image?.withRenderingMode(.alwaysTemplate)
    iconImageView.tintColor = primaryColor
    titleLabel.textColor = primaryColor
    messageLabel.textColor = primaryColor
  }
  
}
