//
//  TextFieldsCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 09.05.2022.
//

import UIKit

protocol TextFieldsCellDelegate: AnyObject {
  func textFieldsCell(_ cell: TextFieldsCell, didEndEditingWith text: String?, at index: Int)
}

class TextFieldsCell: TitleBaseCell {
  
  typealias FieldContent = (placeholder: String?, text: String?, accessibilityIdentifier: String?)
  
  var textFields: [RoundedTextField] { return [] } // Need to override in child class, default is empty
  
  private weak var delegate: TextFieldsCellDelegate?
  
  private let descriptionLabel: UILabel = {
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
  
  final func configure(fieldsContent: [FieldContent],
                       description: String?,
                       attributedDescription: NSAttributedString?,
                       delegate: TextFieldsCellDelegate?) {
    zip(fieldsContent, textFields).forEach { content, textField in
      textField.placeholder = content.placeholder
      textField.text = content.text
      textField.accessibilityIdentifier = content.accessibilityIdentifier
    }
    if let attributedDescription = attributedDescription {
      descriptionLabel.isHidden = false
      descriptionLabel.attributedText = attributedDescription
    } else if let description = description {
      descriptionLabel.isHidden = false
      descriptionLabel.text = description
    } else {
      descriptionLabel.isHidden = true
      descriptionLabel.text = nil
      descriptionLabel.attributedText = nil
    }
    self.delegate = delegate
  }
  
}

// MARK: - UITextFieldDelegate

extension TextFieldsCell: UITextFieldDelegate {
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    guard let index = textFields.firstIndex(where: { $0 === textField }) else { return }
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
    addChildView(descriptionLabel)
  }
  
}
