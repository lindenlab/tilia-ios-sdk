//
//  ColorsConfiguration.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 05.04.2022.
//

import UIKit

final class ColorsConfiguration {
  
  struct Color {
    let lightModeColor: UIColor
    let darkModeColor: UIColor
  }
  
  var backgroundColor: Color?
  var primaryColor: Color?
  var primaryTextColor: Color?
  var successBackgroundColor: Color?
  var failureBackgroundColor: Color?
  
}
