//
//  TextFieldCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 10.05.2022.
//

import UIKit

final class TextFieldCell: TextFieldsCell {
  
  enum InputMode {
    case picker(items: [String], selectedIndex: Int?)
    case datePicker(selectedDate: Date?)
  }
  
  private let firstTextField = RoundedTextField()
  private var pickerDataSource: PickerDataSource?
  private var fieldMask: String? // "xxx-xxx", supports only digits
  private var maskSeparator: Character? // "-"
  
  override var textFields: [RoundedTextField] {
    return [firstTextField]
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    firstTextField.inputView = nil
    firstTextField.inputAccessoryView = nil
    pickerDataSource = nil
    fieldMask = nil
    maskSeparator = nil
    firstTextField.keyboardType = .default
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if let pickerView = textField.inputView as? UIPickerView {
      textField.text = pickerDataSource?.items[pickerView.selectedRow(inComponent: 0)]
    } else if let datePicker = textField.inputView as? UIDatePicker {
      textField.text = datePicker.date.string(formatter: .longDateFormatter)
    }
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard
      let mask = fieldMask,
      let separator = maskSeparator,
      !string.isEmpty else { return true }
    
    guard
      !string.trimmingCharacters(in: CharacterSet.decimalDigits.inverted).isEmpty,
      var newText = textField.text?.newString(forRange: range, withReplacementString: string),
      newText.count <= mask.count else { return false }
    
    let oldText = textField.text ?? ""
    for (index, _) in string.enumerated() {
      let maskIndex = mask.index(oldText.endIndex, offsetBy: index)
      if mask[maskIndex] == separator {
        newText.insert(separator, at: maskIndex)
      }
    }
    
    if newText.count <= mask.count {
      textField.text = newText
    }
    return false
  }
  
  func configure(inputMode: InputMode) {
    switch inputMode {
    case let .picker(items, selectedIndex):
      pickerDataSource = PickerDataSource(items: items) { [weak self] in
        self?.firstTextField.text = $0
      }
      firstTextField.inputView = UIPickerView.pickerView(withDataSource: pickerDataSource,
                                                         andSelectedIndex: selectedIndex)
    case let .datePicker(selectedDate):
      firstTextField.inputView = UIDatePicker.datePicker(withSelectedDate: selectedDate,
                                                         forTarget: self,
                                                         andSelector: #selector(datePickerDidChange(_:)))
    }
    firstTextField.inputAccessoryView = UIToolbar.toolbar(forTarget: self,
                                                          andSelector: #selector(doneButtonTapped))
  }
  
  func configure(mask: String, separator: Character = "-") {
    fieldMask = mask
    maskSeparator = separator
    firstTextField.keyboardType = .numberPad
    firstTextField.inputAccessoryView = UIToolbar.toolbar(forTarget: self,
                                                          andSelector: #selector(doneButtonTapped))
  }
  
}

// MARK: - Private Methods

private extension TextFieldCell {
  
  @objc func datePickerDidChange(_ sender: UIDatePicker) {
    firstTextField.text = sender.date.string(formatter: .longDateFormatter)
  }
  
  @objc func doneButtonTapped() {
    firstTextField.resignFirstResponder()
  }
  
}
