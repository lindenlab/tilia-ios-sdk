//
//  UserDocumentsImageCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 29.07.2022.
//

import UIKit

final class UserDocumentsImageCell: UITableViewCell {
  
  private let contentImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  func configure(image: UIImage?) {
    contentImageView.image = image
  }
  
}

// MARK: - Private Methods

private extension UserDocumentsImageCell {
  
  func setup() {
    selectionStyle = .none
    backgroundColor = .backgroundColor
    contentView.backgroundColor = .backgroundColor
    
    contentView.addSubview(contentImageView)

    NSLayoutConstraint.activate([
      contentImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      contentImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      contentImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
      contentImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
    ])
  }
  
}
