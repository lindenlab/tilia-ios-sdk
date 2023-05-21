//
//  TextFieldsCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 09.05.2022.
//

import UIKit

protocol TextFieldsCellDelegate: AnyObject, TextViewWithLinkDelegate {
  func textFieldsCell(_ cell: TextFieldsCell, didEndEditingWith text: String?, at index: Int)
  func textFieldsCell(_ cell: TextFieldsCell, didEditAt index: Int)
}

extension TextFieldsCellDelegate {
  
  func textFieldsCell(_ cell: TextFieldsCell, didEditAt index: Int) { }
  func textViewWithLink(_ textView: TextViewWithLink, didPressOn link: String) { }
  
}

class TextFieldsCell: TitleBaseCell {
  
  struct FieldContent {
    let placeholder: String?
    let text: String?
    let accessibilityIdentifier: String?
    let isUserInteractionEnabled: Bool
    let isEditButtonHidden: Bool
    
    init(placeholder: String? = nil,
         text: String? = nil,
         accessibilityIdentifier: String? = nil,
         isUserInteractionEnabled: Bool = true,
         isEditButtonHidden: Bool = true) {
      self.placeholder = placeholder
      self.text = text
      self.accessibilityIdentifier = accessibilityIdentifier
      self.isUserInteractionEnabled = isUserInteractionEnabled
      self.isEditButtonHidden = isEditButtonHidden
    }
  }
    
  var textFields: [RoundedTextField] { return [] } // Need to override in child class, default is empty
  
  private weak var delegate: TextFieldsCellDelegate?
  
  private let descriptionTextView: TextViewWithLink = {
    let textView = TextViewWithLink()
    textView.font = .systemFont(ofSize: 14)
    textView.textColor = .tertiaryTextColor
    return textView
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  final func configure(fieldsContent: [FieldContent],
                       description: String? = nil,
                       attributedDescription: NSAttributedString? = nil,
                       descriptionTextData: TextViewWithLink.TextData? = nil,
                       descriptionAdditionalAttributes: [TextViewWithLink.AdditionalAttribute]? = nil,
                       delegate: TextFieldsCellDelegate?) {
    zip(fieldsContent, textFields).forEach { content, textField in
      textField.placeholder = content.placeholder
      textField.text = content.text
      textField.accessibilityIdentifier = content.accessibilityIdentifier
      textField.isUserInteractionEnabled = content.isUserInteractionEnabled
      textField.rightView = content.isEditButtonHidden ? nil : editButton()
      textField.rightViewMode = content.isEditButtonHidden ? .never : .always
    }
    if let attributedDescription = attributedDescription {
      descriptionTextView.isHidden = false
      descriptionTextView.attributedText = attributedDescription
    } else if let description = description {
      descriptionTextView.isHidden = false
      descriptionTextView.text = description
    } else if let descriptionTextData = descriptionTextData {
      descriptionTextView.isHidden = false
      descriptionTextView.textData = descriptionTextData
      descriptionTextView.additionalAttributes = descriptionAdditionalAttributes ?? []
      descriptionTextView.linkDelegate = delegate
    } else {
      descriptionTextView.isHidden = true
      descriptionTextView.text = nil
      descriptionTextView.attributedText = nil
    }
    self.delegate = delegate
  }
  
}

// MARK: - UITextFieldDelegate

extension TextFieldsCell: UITextFieldDelegate {
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    guard let index = self.index(of: textField) else { return }
    delegate?.textFieldsCell(self,
                             didEndEditingWith: textField.text,
                             at: index)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
}

// MARK: - Private Methods

private extension TextFieldsCell {
  
  func setup() {
    textFields.forEach {
      addChildView($0)
      $0.delegate = self
      $0.returnKeyType = .done
    }
    addChildView(descriptionTextView)
  }
  
  func index(of textField: UITextField) -> Int? {
    return textFields.firstIndex(where: { $0 === textField })
  }
  
  func editButton() -> UIButton {
    let button = EditButton()
    button.addTarget(self, action: #selector(editButtonDidTap(_:)), for: .touchUpInside)
    return button
  }
  
  @objc func editButtonDidTap(_ sender: UIButton) {
    guard
      let textField = sender.superview as? UITextField,
      let index = self.index(of: textField) else { return }
    delegate?.textFieldsCell(self, didEditAt: index)
  }
  
}
