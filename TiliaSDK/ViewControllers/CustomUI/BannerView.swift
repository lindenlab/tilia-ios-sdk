//
//  BannerView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 01.04.2022.
//

import UIKit

final class BannerView: UIView {
  
  enum State {
    case success
    case error
  }
  
  private let state: State
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .logoImage
    return imageView
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 16)
    label.textColor = .white
    return label
  }()
  
  private let messageLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 16)
    label.textColor = .white
    label.numberOfLines = 0
    return label
  }()
  
  init(frame: CGRect = .zero, state: State, title: String, message: String) {
    self.state = state
    super.init(frame: frame)
    setup(state: state, title: title, message: message)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Private Methods

private extension BannerView {
  
  func setup(state: State, title: String, message: String) {
    titleLabel.text = title
    messageLabel.text = message
    
    switch state {
    case .success:
      backgroundColor = .customGreen
    case .error:
      backgroundColor = .customRed
    }
    clipsToBounds = true
    layer.cornerRadius = 6
    
    let labelsStackView = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
    labelsStackView.spacing = 10
    labelsStackView.axis = .vertical
    let stackView = UIStackView(arrangedSubviews: [imageView, labelsStackView])
    stackView.alignment = .top
    stackView.spacing = 16
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
      stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
    ])
  }
  
}
