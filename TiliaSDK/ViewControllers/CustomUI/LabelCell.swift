//
//  LabelCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 09.05.2022.
//

import UIKit

final class LabelCell: TitleBaseCell {
  
  private let textView: TextViewWithLink = {
    let textView = TextViewWithLink()
    textView.font = .systemFont(ofSize: 16)
    return textView
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(description: String?,
                 attributedDescription: NSAttributedString?,
                 textColor: UIColor = .secondaryTextColor,
                 textData: TextViewWithLink.TextData? = nil,
                 delegate: TextViewWithLinkDelegate?) {
    textView.textColor = textColor
    if let attributedDescription = attributedDescription {
      textView.isHidden = false
      textView.attributedText = attributedDescription
    } else if let description = description {
      textView.isHidden = false
      textView.text = description
    } else if let textData = textData {
      textView.isHidden = false
      textView.textData = textData
      textView.linkDelegate = delegate
    } else {
      textView.isHidden = true
      textView.text = nil
      textView.attributedText = nil
    }
  }
  
}

// MARK: - Private Methods

private extension LabelCell {
  
  func setup() {
    addChildView(textView)
  }
  
}
