//
//  TextFieldCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 10.05.2022.
//

import UIKit

final class TextFieldCell: TextFieldsCell {
  
  private let firstTextField = RoundedTextField()
  
  override var textFields: [RoundedTextField] {
    return [firstTextField]
  }
  
}
