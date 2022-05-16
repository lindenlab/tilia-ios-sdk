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
  private var pickerDataSource: DatePickerDataSource?
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
      textField.text = datePicker.date.string()
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
      firstTextField.inputView = pickerView(items: items, selectedIndex: selectedIndex)
    case let .datePicker(selectedDate):
      firstTextField.inputView = datePicker(selectedDate: selectedDate)
    }
  }
  
  func configure(mask: String, separator: Character = "-") {
    fieldMask = mask
    maskSeparator = separator
    firstTextField.keyboardType = .numberPad
  }
  
}

// MARK: - Private Methods

private extension TextFieldCell {
  
  final class DatePickerDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let items: [String]
    private let selectHandler: (String) -> Void
    
    init(items: [String], selectHandler: @escaping (String) -> Void) {
      self.items = items
      self.selectHandler = selectHandler
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return items[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      selectHandler(items[row])
    }
    
  }
  
  func pickerView(items: [String], selectedIndex: Int?) -> UIPickerView {
    let pickerDataSource = DatePickerDataSource(items: items) { [weak self] in
      self?.firstTextField.text = $0
    }
    self.pickerDataSource = pickerDataSource
    let picketView = UIPickerView()
    picketView.dataSource = pickerDataSource
    picketView.delegate = pickerDataSource
    selectedIndex.map {
      picketView.selectRow($0, inComponent: 0, animated: false)
    }
    return picketView
  }
  
  func datePicker(selectedDate: Date?) -> UIDatePicker {
    let datePicker = UIDatePicker()
    datePicker.addTarget(self,
                         action: #selector(datePickerDidChange(_:)),
                         for: .valueChanged)
    datePicker.datePickerMode = .date
    if #available(iOS 14, *) {
      datePicker.preferredDatePickerStyle = .inline
    } else if #available(iOS 13.4, *) {
      datePicker.preferredDatePickerStyle = .wheels
    }
    selectedDate.map {
      datePicker.setDate($0, animated: false)
    }
    return datePicker
  }
  
  @objc func datePickerDidChange(_ sender: UIDatePicker) {
    firstTextField.text = sender.date.string()
  }
  
}
