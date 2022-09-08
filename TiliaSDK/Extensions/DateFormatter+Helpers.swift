//
//  DateFormatter+Helpers.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 10.05.2022.
//

import Foundation

extension DateFormatter {
  
  static var longDateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
  }
  
  static var shortTimeFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
  }
  
  static var longDateAndShortTimeFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .short
    return formatter
  }
  
  static var customDateAndTimeFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "YY, MMM d, HH:mm:ss"
    return formatter
  }
  
  static var customDateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }
  
  static var customDateAndTimeWithTimeZoneFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS Z zzz"
    return formatter
  }
  
}
