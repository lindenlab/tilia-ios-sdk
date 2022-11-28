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
  
  func formattedDefaultDescription(showTimeZone: Bool = true) -> String {
    let description: String
    if Calendar.current.isDateInToday(self) {
      description = L.todayAt(with: string(formatter: .shortTimeFormatter))
    } else if Calendar.current.isDateInYesterday(self) {
      description = L.yesterdayAt(with: string(formatter: .shortTimeFormatter))
    } else {
      description = string(formatter: .longDateAndShortTimeFormatter)
    }
    if showTimeZone, let abbreviation = TimeZone.current.abbreviation(for: self) {
      return "\(description) (\(abbreviation))"
    } else {
      return description
    }
  }
  
  func formattedRequestedDescription(showTimeZone: Bool = true) -> String {
    let description: String
    if Calendar.current.isDateInToday(self) {
      description = L.requestedTodayAt(with: string(formatter: .shortTimeFormatter))
    } else if Calendar.current.isDateInYesterday(self) {
      description = L.requestedYesterdayAt(with: string(formatter: .shortTimeFormatter))
    } else {
      description = L.requestedOn(with: string(formatter: .longDateAndShortTimeFormatter))
    }
    if showTimeZone, let abbreviation = TimeZone.current.abbreviation(for: self) {
      return "\(description) (\(abbreviation))"
    } else {
      return description
    }
  }
  
  func longDateDescription(showTimeZone: Bool = true) -> String {
    let description = string(formatter: .longDateFormatter)
    if showTimeZone, let abbreviation = TimeZone.current.abbreviation(for: self) {
      return "\(description) (\(abbreviation))"
    } else {
      return description
    }
  }
  
  func shortTimeDescription(showTimeZone: Bool = true) -> String {
    let description = string(formatter: .shortTimeFormatter)
    if showTimeZone, let abbreviation = TimeZone.current.abbreviation(for: self) {
      return "\(description) (\(abbreviation))"
    } else {
      return description
    }
  }
  
  func getDateDiff(for date: Date) -> Int {
    let calendar = Calendar.current
    let fromDate = calendar.startOfDay(for: self)
    let toDate = calendar.startOfDay(for: date)
    let value = calendar.dateComponents([.day], from: fromDate, to: toDate).day ?? 0
    return abs(value)
  }
  
}
