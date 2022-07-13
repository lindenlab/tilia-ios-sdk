//
//  CountryModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 13.07.2022.
//

import Foundation

struct CountryModel: PossiblyEmpty {
  
  let name: String
  let code: String
  
  var isEmpty: Bool { return name.isEmpty || code.isEmpty }
  var isUs: Bool { return code == "US" }
  var states: [CountryStateModel]? {
    switch code {
    case "US": return CountryStateModel.usStates
    case "CA": return CountryStateModel.canadaStates
    default: return nil
    }
  }
  
  static let countries: [CountryModel] = {
    return Locale.isoRegionCodes.map { .init(name: Locale.current.localizedString(forRegionCode: $0) ?? "",
                                             code: $0) }
  }()
  
  static let countryNames: [String] = {
    return Locale.isoRegionCodes.compactMap { Locale.current.localizedString(forRegionCode: $0) }
  }()
  
}
