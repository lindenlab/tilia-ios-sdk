//
//  TwoTextFieldsCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 10.05.2022.
//

import UIKit

final class TwoTextFieldsCell: TextFieldsCell {
  
  private let firstTextField = RoundedTextField()
  private let secondTextField = RoundedTextField()
  
  override var textFields: [RoundedTextField] {
    return [firstTextField, secondTextField]
  }
  
}
