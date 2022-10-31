//
//  DateTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 27.10.2022.
//

import XCTest
@testable import TiliaSDK

final class DateTests: XCTestCase {
  
  func testString() {
    let date = Date()
    let formatter = DateFormatter.longDateAndShortTimeFormatter
    XCTAssertEqual(date.string(formatter: formatter), formatter.string(from: date))
  }
  
  func testFormattedDefaultDescriptionWithoutTimeZone() {
    let todayDate = Date()
    let yesterdayDate = Date(timeInterval: -60*60*24, since: todayDate)
    let pastDate = Date(timeInterval: -60*60*24*2, since: todayDate)
    let todayDescription = L.todayAt(with: todayDate.string(formatter: .shortTimeFormatter))
    let yesterdayDescription = L.yesterdayAt(with: yesterdayDate.string(formatter: .shortTimeFormatter))
    let pastDescription = pastDate.string(formatter: .longDateAndShortTimeFormatter)
    XCTAssertEqual(todayDate.formattedDefaultDescription(showTimeZone: false), todayDescription)
    XCTAssertEqual(yesterdayDate.formattedDefaultDescription(showTimeZone: false), yesterdayDescription)
    XCTAssertEqual(pastDate.formattedDefaultDescription(showTimeZone: false), pastDescription)
  }
  
  func testFormattedDefaultDescriptionWithTimeZone() {
    let todayDate = Date()
    let yesterdayDate = Date(timeInterval: -60*60*24, since: todayDate)
    let pastDate = Date(timeInterval: -60*60*24*2, since: todayDate)
    let todayTimeZone = TimeZone.current.abbreviation(for: todayDate) ?? ""
    let yesterdayTimeZone = TimeZone.current.abbreviation(for: yesterdayDate) ?? ""
    let pastTimeZone = TimeZone.current.abbreviation(for: pastDate) ?? ""
    let todayDescription = L.todayAt(with: todayDate.string(formatter: .shortTimeFormatter)) + " (\(todayTimeZone))"
    let yesterdayDescription = L.yesterdayAt(with: yesterdayDate.string(formatter: .shortTimeFormatter)) + " (\(yesterdayTimeZone))"
    let pastDescription = pastDate.string(formatter: .longDateAndShortTimeFormatter) + " (\(pastTimeZone))"
    XCTAssertEqual(todayDate.formattedDefaultDescription(), todayDescription)
    XCTAssertEqual(yesterdayDate.formattedDefaultDescription(), yesterdayDescription)
    XCTAssertEqual(pastDate.formattedDefaultDescription(), pastDescription)
  }
  
  func testFormattedRequestedDescriptionWithoutTimeZone() {
    let todayDate = Date()
    let yesterdayDate = Date(timeInterval: -60*60*24, since: todayDate)
    let pastDate = Date(timeInterval: -60*60*24*2, since: todayDate)
    let todayDescription = L.requestedTodayAt(with: todayDate.string(formatter: .shortTimeFormatter))
    let yesterdayDescription = L.requestedYesterdayAt(with: yesterdayDate.string(formatter: .shortTimeFormatter))
    let pastDescription = L.requestedOn(with: pastDate.string(formatter: .longDateAndShortTimeFormatter))
    XCTAssertEqual(todayDate.formattedRequestedDescription(showTimeZone: false), todayDescription)
    XCTAssertEqual(yesterdayDate.formattedRequestedDescription(showTimeZone: false), yesterdayDescription)
    XCTAssertEqual(pastDate.formattedRequestedDescription(showTimeZone: false), pastDescription)
  }
  
  func testFormattedRequestedDescriptionWithTimeZone() {
    let todayDate = Date()
    let yesterdayDate = Date(timeInterval: -60*60*24, since: todayDate)
    let pastDate = Date(timeInterval: -60*60*24*2, since: todayDate)
    let todayTimeZone = TimeZone.current.abbreviation(for: todayDate) ?? ""
    let yesterdayTimeZone = TimeZone.current.abbreviation(for: yesterdayDate) ?? ""
    let pastTimeZone = TimeZone.current.abbreviation(for: pastDate) ?? ""
    let todayDescription = L.requestedTodayAt(with: todayDate.string(formatter: .shortTimeFormatter)) + " (\(todayTimeZone))"
    let yesterdayDescription = L.requestedYesterdayAt(with: yesterdayDate.string(formatter: .shortTimeFormatter)) + " (\(yesterdayTimeZone))"
    let pastDescription = L.requestedOn(with: pastDate.string(formatter: .longDateAndShortTimeFormatter)) + " (\(pastTimeZone))"
    XCTAssertEqual(todayDate.formattedRequestedDescription(), todayDescription)
    XCTAssertEqual(yesterdayDate.formattedRequestedDescription(), yesterdayDescription)
    XCTAssertEqual(pastDate.formattedRequestedDescription(), pastDescription)
  }
  
  func testLongDateDescriptionWithoutTimeZone() {
    let date = Date()
    let formatter = DateFormatter.longDateFormatter
    XCTAssertEqual(date.longDateDescription(showTimeZone: false), formatter.string(from: date))
  }
  
  func testLongDateDescriptionWithTimeZone() {
    let date = Date()
    let formatter = DateFormatter.longDateFormatter
    let timeZone = TimeZone.current.abbreviation(for: date) ?? ""
    let description = "\(formatter.string(from: date)) (\(timeZone))"
    XCTAssertEqual(date.longDateDescription(), description)
  }
  
  func testShortDateDescriptionWithoutTimeZone() {
    let date = Date()
    let formatter = DateFormatter.shortTimeFormatter
    XCTAssertEqual(date.shortTimeDescription(showTimeZone: false), formatter.string(from: date))
  }
  
  func testShortDateDescriptionWithTimeZone() {
    let date = Date()
    let formatter = DateFormatter.shortTimeFormatter
    let timeZone = TimeZone.current.abbreviation(for: date) ?? ""
    let description = "\(formatter.string(from: date)) (\(timeZone))"
    XCTAssertEqual(date.shortTimeDescription(), description)
  }
  
  func testGetDateDiff() {
    let todayDate = Date()
    let yesterdayDate = Date(timeInterval: -60*60*24, since: todayDate)
    let pastDate = Date(timeInterval: -60*60*24*2, since: todayDate)
    XCTAssertEqual(todayDate.getDateDiff(for: todayDate), 0)
    XCTAssertEqual(todayDate.getDateDiff(for: yesterdayDate), 1)
    XCTAssertEqual(todayDate.getDateDiff(for: pastDate), 2)
  }
  
}
