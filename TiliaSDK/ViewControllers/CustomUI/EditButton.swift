//
//  EditButton.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 18.05.2023.
//

import UIKit

final class EditButton: UIButton {
  
  override init(frame: CGRect = .zero) {
    super.init(frame: frame)
    setImage(.pencilIcon?.withRenderingMode(.alwaysTemplate),
             for: .normal)
    imageView?.tintColor = .primaryTextColor
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
