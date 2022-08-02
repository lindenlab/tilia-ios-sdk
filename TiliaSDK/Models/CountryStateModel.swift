//
//  CountryStateModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 13.07.2022.
//

import Foundation

struct CountryStateModel: PossiblyEmpty {
  
  var name: String?
  let code: String?
  
  var isEmpty: Bool { return name.isEmpty }
  
  static let usStates: [CountryStateModel] = [
    .init(name: "Alaska", code: "AK"),
    .init(name: "Alabama", code: "AL"),
    .init(name: "Arkansas", code: "AR"),
    .init(name: "Arizona", code: "AZ"),
    .init(name: "California", code: "CA"),
    .init(name: "Colorado", code: "CO"),
    .init(name: "Connecticut", code: "CT"),
    .init(name: "District of Columbia", code: "DC"),
    .init(name: "Delaware", code: "DE"),
    .init(name: "Florida", code: "FL"),
    .init(name: "Georgia", code: "GA"),
    .init(name: "Guam", code: "GU"),
    .init(name: "Hawaii", code: "HI"),
    .init(name: "Iowa", code: "IA"),
    .init(name: "Idaho", code: "ID"),
    .init(name: "Illinois", code: "IL"),
    .init(name: "Indiana", code: "IN"),
    .init(name: "Kansas", code: "KS"),
    .init(name: "Kentucky", code: "KY"),
    .init(name: "Louisiana", code: "LA"),
    .init(name: "Massachusetts", code: "MA"),
    .init(name: "Maryland", code: "MD"),
    .init(name: "Maine", code: "ME"),
    .init(name: "Michigan", code: "MI"),
    .init(name: "Minnesota", code: "MN"),
    .init(name: "Missouri", code: "MO"),
    .init(name: "Mississippi", code: "MS"),
    .init(name: "Montana", code: "MT"),
    .init(name: "North Carolina", code: "NC"),
    .init(name: "North Dakota", code: "ND"),
    .init(name: "Nebraska", code: "NE"),
    .init(name: "New Hampshire", code: "NH"),
    .init(name: "New Jersey", code: "NJ"),
    .init(name: "New Mexico", code: "NM"),
    .init(name: "Nevada", code: "NV"),
    .init(name: "New York", code: "NY"),
    .init(name: "Ohio", code: "OH"),
    .init(name: "Oklahoma", code: "OK"),
    .init(name: "Oregon", code: "OR"),
    .init(name: "Pennsylvania", code: "PA"),
    .init(name: "Puerto Rico", code: "PR"),
    .init(name: "Rhode Island", code: "RI"),
    .init(name: "South Carolina", code: "SC"),
    .init(name: "South Dakota", code: "SD"),
    .init(name: "Tennessee", code: "TN"),
    .init(name: "Texas", code: "TX"),
    .init(name: "Utah", code: "UT"),
    .init(name: "Virginia", code: "VA"),
    .init(name: "Virgin Islands", code: "VI"),
    .init(name: "Vermont", code: "VT"),
    .init(name: "Washington", code: "WA"),
    .init(name: "Wisconsin", code: "WI"),
    .init(name: "West Virginia", code: "WV"),
    .init(name: "Wyoming", code: "WY"),
    .init(name: "Army Europe", code: "AE"),
    .init(name: "Army Pacific", code: "AP"),
    .init(name: "Army Americas", code: "AA")
  ]
  
  static let canadaStates: [CountryStateModel] = [
    .init(name: "Alberta", code: "AB"),
    .init(name: "British Columbia", code: "BC"),
    .init(name: "Manitoba", code: "MB"),
    .init(name: "New Brunswick", code: "NB"),
    .init(name: "Newfoundland", code: "NL"),
    .init(name: "Northwest Territories", code: "NT"),
    .init(name: "Nova Scotia", code: "NS"),
    .init(name: "Nunavut", code: "NU"),
    .init(name: "Ontario", code: "ON"),
    .init(name: "Prince Edward Island", code: "PE"),
    .init(name: "Quebec", code: "QC"),
    .init(name: "Saskatchewan", code: "SK"),
    .init(name: "Yukon Territory", code: "YT")
  ]
  
  init(name: String? = nil, code: String? = nil) {
    self.name = name
    self.code = code
  }
  
}
