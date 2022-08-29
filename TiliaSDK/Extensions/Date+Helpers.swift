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
  
  func formattedDescription(showTimeZone: Bool = true) -> String {
    let description: String
    if Calendar.current.isDateInToday(self) {
      description = L.todayAt(with: DateFormatter.shortTimeFormatter.string(from: self))
    } else if Calendar.current.isDateInYesterday(self) {
      description = L.yesterdayAt(with: DateFormatter.shortTimeFormatter.string(from: self))
    } else {
      description = DateFormatter.longDateAndShortTimeFormatter.string(from: self)
    }
    if showTimeZone, let abbreviation = TimeZone.current.abbreviation(for: self) {
      return "\(description) (\(abbreviation))"
    } else {
      return description
    }
  }
  
}
