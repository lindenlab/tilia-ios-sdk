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
  var isUs: Bool { return code == Self.usaCode }
  var states: [CountryStateModel]? {
    switch code {
    case Self.usaCode: return CountryStateModel.usStates
    case Self.canadaCode: return CountryStateModel.canadaStates
    default: return nil
    }
  }
  
  static let countries: [CountryModel] = {
    var items: [CountryModel] = [.usa, .canada]
    let disabledCodes = Self.disabledCodes
    for code in Locale.isoRegionCodes where !disabledCodes.contains(code) {
      items.append(.init(name: Locale.current.localizedString(forRegionCode: code) ?? "",
                         code: code))
    }
    return items
  }()
  
  static let countryNames: [String] = {
    var items: [String] = [Self.usa.name, Self.canada.name]
    let disabledCodes = Self.disabledCodes
    for code in Locale.isoRegionCodes where !disabledCodes.contains(code) {
      items.append(Locale.current.localizedString(forRegionCode: code) ?? "")
    }
    return items
  }()
  
  private static let usaCode = "US"
  private static let canadaCode = "CA"
  
  private static let usa: CountryModel = {
    let code = Self.usaCode
    return .init(name: Locale.current.localizedString(forRegionCode: code) ?? "",
                 code: code)
  }()
  
  private static let canada: CountryModel = {
    let code = Self.canadaCode
    return .init(name: Locale.current.localizedString(forRegionCode: code) ?? "",
                 code: code)
  }()
  
  private static let disabledCodes: Set<String> = [Self.usaCode, Self.canadaCode]
  
}
