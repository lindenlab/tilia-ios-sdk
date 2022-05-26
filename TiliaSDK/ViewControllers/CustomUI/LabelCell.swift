//
//  LabelCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 09.05.2022.
//

import UIKit

class LabelCell: TitleBaseCell {
  
  private let label: UILabel = {
    let label = UILabel()
    label.textColor = .secondaryTextColor
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
  
  func configure(description: String?, font: UIFont = .systemFont(ofSize: 16)) {
    label.text = description
    label.font = font
  }
  
}

// MARK: - Private Methods

private extension LabelCell {
  
  func setup() {
    addChildView(label)
  }
  
}
