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
    imageView.tintColor = .primaryColor
    imageView.contentMode = .center
    return imageView
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(image: UIImage?) {
    contentImageView.image = image?.withRenderingMode(.alwaysTemplate)
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
