//
//  NonPrimaryButtonWithImageCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 06.05.2022.
//

import UIKit

protocol NonPrimaryButtonWithImageCellDelegate: AnyObject {
  func nonPrimaryButtonWithImageCellButtonDidTap(_ cell: NonPrimaryButtonWithImageCell)
}

final class NonPrimaryButtonWithImageCell: TitleBaseCell {
  
  private weak var delegate: NonPrimaryButtonWithImageCellDelegate?
  
  private let button: NonPrimaryButtonWithStyle = {
    let button = NonPrimaryButtonWithStyle(.titleAndImageFill)
    button.setImage(.bottomArrowIcon, for: .normal)
    return button
  }()
  
  private let label: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 14)
    label.textColor = .tertiaryTextColor
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
  
  func configure(buttonPlaceholder: String,
                 buttonTitle: String?,
                 description: String?,
                 delegate: NonPrimaryButtonWithImageCellDelegate?) {
    button.placeholder = buttonPlaceholder
    button.setTitle(buttonTitle, for: .normal)
    label.text = description
    label.isHidden = description == nil
    self.delegate = delegate
  }
  
}

// MARK: - Private Methods

private extension NonPrimaryButtonWithImageCell {
  
  func setup() {
    button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
    addChildView(button)
    addChildView(label)
  }
  
  @objc func buttonDidTap() {
    delegate?.nonPrimaryButtonWithImageCellButtonDidTap(self)
  }
  
}
