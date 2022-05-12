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
    label.font = .systemFont(ofSize: 16)
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
  
  func configure(description: String?) {
    label.text = description
  }
  
}

// MARK: - Private Methods

private extension LabelCell {
  
  func setup() {
    addChildView(label)
  }
  
}
