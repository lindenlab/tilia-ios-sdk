//
//  Date+Helpers.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 10.05.2022.
//

import Foundation

extension Date {
  
  func string(formatter: DateFormatter) -> String {
    return formatter.string(from: self)
  }
  
}
