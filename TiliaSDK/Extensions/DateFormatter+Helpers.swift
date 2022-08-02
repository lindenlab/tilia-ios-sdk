//
//  DateFormatter+Helpers.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 10.05.2022.
//

import Foundation

extension DateFormatter {
  
  static var defaultFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
  }
  
}
