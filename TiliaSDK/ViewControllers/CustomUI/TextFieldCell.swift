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
  
  override var textFields: [RoundedTextField] {
    return [firstTextField]
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    firstTextField.inputView = nil
    firstTextField.inputAccessoryView = nil
    pickerDataSource = nil
  }
  
  func configure(inputMode: InputMode) {
    switch inputMode {
    case let .picker(items, selectedIndex):
      firstTextField.inputView = pickerView(items: items, selectedIndex: selectedIndex)
    case let .datePicker(selectedDate):
      firstTextField.inputView = datePicker(selectedDate: selectedDate)
    }
  }
  
}

// MARK: - Private Methods

private extension TextFieldCell {
  
  final class DatePickerDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    private let items: [String]
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
    let pickerView = firstTextField.inputView as? UIDatePicker
    firstTextField.text = pickerView?.date.string()
  }
  
}
