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
  
  private let button: NonPrimaryButtonWithImage = {
    let button = NonPrimaryButtonWithImage(style: .titleAndImageFill)
    button.setImage(.bottomArrowIcon, for: .normal)
    return button
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
                 delegate: NonPrimaryButtonWithImageCellDelegate?) {
    button.placeholder = buttonPlaceholder
    button.setTitle(buttonTitle, for: .normal)
    self.delegate = delegate
  }
  
}

// MARK: - Private Methods

private extension NonPrimaryButtonWithImageCell {
  
  func setup() {
    button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
    addChildView(button)
  }
  
  @objc func buttonDidTap() {
    delegate?.nonPrimaryButtonWithImageCellButtonDidTap(self)
  }
  
}
