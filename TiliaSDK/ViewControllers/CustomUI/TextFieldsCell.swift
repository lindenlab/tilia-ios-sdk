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
  
  typealias Content = (placeholder: String?, text: String?)
  
  var textFields: [RoundedTextField] { return [] } // Need to override in child class, default is empty
  
  private weak var delegate: TextFieldsCellDelegate?
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    textFields.forEach {
      addChildView($0)
      $0.delegate = self
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  final func configure(content: Content..., delegate: TextFieldsCellDelegate?) {
    zip(content, textFields).forEach { content, textField in
      textField.placeholder = content.placeholder
      textField.text = content.text
    }
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
  
}

final class TextFieldCell: TextFieldsCell {
  
  private let firstTextField = RoundedTextField()
  
  override var textFields: [RoundedTextField] {
    return [firstTextField]
  }
  
}

final class TwoTextFieldsCell: TextFieldsCell {
  
  private let firstTextField = RoundedTextField()
  private let secondTextField = RoundedTextField()
  
  override var textFields: [RoundedTextField] {
    return [firstTextField, secondTextField]
  }
  
}

final class ThreeTextFieldsCell: TextFieldsCell {
  
  private let firstTextField = RoundedTextField()
  private let secondTextField = RoundedTextField()
  private let thirdTextField = RoundedTextField()
  
  override var textFields: [RoundedTextField] {
    return [firstTextField, secondTextField, thirdTextField]
  }
  
}
