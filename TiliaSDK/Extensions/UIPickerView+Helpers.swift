//
//  UIPickerView+Helpers.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 31.05.2023.
//

import UIKit

final class PickerDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
  
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

extension UIPickerView {
  
  static func pickerView(withDataSource dataSource: PickerDataSource?, andSelectedIndex selectedIndex: Int?) -> UIPickerView {
    let picketView = UIPickerView()
    picketView.dataSource = dataSource
    picketView.delegate = dataSource
    selectedIndex.map {
      picketView.selectRow($0, inComponent: 0, animated: false)
    }
    return picketView
  }
  
}

extension UIDatePicker {
  
  static func datePicker(withSelectedDate selectedDate: Date?, forTarget target: Any?, andSelector selector: Selector) -> UIDatePicker {
    let datePicker = UIDatePicker()
    datePicker.addTarget(target,
                         action: selector,
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
  
}

extension UIToolbar {
  
  static func toolbar(forTarget target: Any?, andSelector selector: Selector?) -> UIToolbar {
    let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                     target: target,
                                     action: selector)
    let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                     target: nil,
                                     action: nil)
    let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
    let toolbar = UIToolbar(frame: frame)
    toolbar.sizeToFit()
    toolbar.setItems([flexButton, doneButton], animated: false)
    return toolbar
  }
  
}
