//
//  LabelCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 09.05.2022.
//

import UIKit

final class LabelCell: TitleBaseCell {
  
  private let label: UILabel = {
    let label = UILabel()
    label.textColor = .secondaryTextColor
    label.numberOfLines = 0
    label.font = .systemFont(ofSize: 16)
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(description: String?, attributedDescription: NSAttributedString?) {
    if let attributedDescription = attributedDescription {
      label.attributedText = attributedDescription
    } else if let description = description {
      label.text = description
    } else {
      label.text = nil
      label.attributedText = nil
    }
  }
  
}

// MARK: - Private Methods

private extension LabelCell {
  
  func setup() {
    addChildView(label)
  }
  
}
