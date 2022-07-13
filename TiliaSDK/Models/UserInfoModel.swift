//
//  UserInfoModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 07.05.2022.
//

import UIKit
import PDFKit

final class UserInfoModel {
  
  var countryOfResidence: Country?
  var fullName: FullName = FullName()
  var dateOfBirth: Date?
  var address: Address = Address(region: CountryState())
  var canUseAddressFor1099: BoolModel?
  var tax: Tax?
  
  var document: Document?
  var frontImage: UIImage?
  var backImage: UIImage?
  lazy var documentCountry: Country? = countryOfResidence
  var isAddressOnDocument: BoolModel?
  var additionalDocuments: [AdditionalDocument] = []
  
  var isUsDocumentCountry: Bool { return documentCountry?.isUs == true }
  var isUsResident: Bool { return countryOfResidence?.isUs == true }
  var dateOfBirthString: String? { return dateOfBirth.map { $0.string() } }
  
  func setAddressToDefault() {
    address.street = nil
    address.apartment = nil
    address.city = nil
    address.region.name = nil
    address.postalCode = nil
    canUseAddressFor1099 = nil
  }
  
  func setDocumentImagesToDefault() {
    frontImage = nil
    backImage = nil
  }
  
}

// MARK: - Additional Models

extension UserInfoModel {
  
  struct FullName {
    var first: String?
    var middle: String?
    var last: String?
  }
  
  struct Address {
    var street: String?
    var apartment: String?
    var city: String?
    var region: CountryState
    var postalCode: String?
  }
  
  struct Tax: PossiblyEmpty {
    var ssn: String?
    var signature: String?
    
    var isEmpty: Bool { return ssn.isEmpty || signature.isEmpty }
  }
  
  struct CountryState: PossiblyEmpty {
    var name: String?
    let code: String?
    
    var isEmpty: Bool { return name.isEmpty }
    
    init(name: String? = nil, code: String? = nil) {
      self.name = name
      self.code = code
    }
  }
  
  struct Country: PossiblyEmpty {
    let name: String
    let code: String
    
    var isEmpty: Bool { return name.isEmpty || code.isEmpty }
    var isUs: Bool { return code == "US" }
    var states: [CountryState]? {
      switch code {
      case "US": return CountryState.usStates
      case "CA": return CountryState.canadaStates
      default: return nil
      }
    }
  }
  
  enum BoolModel: CustomStringConvertible, CaseIterable {
    case yes
    case no
    
    var description: String {
      switch self {
      case .yes: return L.yes
      case .no: return L.no
      }
    }
    
    init?(str: String) {
      switch str {
      case BoolModel.yes.description: self = .yes
      case BoolModel.no.description: self = .no
      default: return nil
      }
    }
  }
  
  enum Document: CustomStringConvertible, CaseIterable {
    case passport
    case driversLicense
    case identityCard
    case residencePermit
    
    var description: String {
      switch self {
      case .passport: return L.passport
      case .driversLicense: return L.driversLicense
      case .identityCard: return L.identityCard
      case .residencePermit: return L.residencePermit
      }
    }
    
    init?(str: String) {
      switch str {
      case Document.passport.description: self = .passport
      case Document.driversLicense.description: self = .driversLicense
      case Document.identityCard.description: self = .identityCard
      case Document.residencePermit.description: self = .residencePermit
      default: return nil
      }
    }
  }
  
  enum AdditionalDocument {
    case pdfFile(PDFDocument)
    case image(UIImage)
  }
  
}

// MARK: - States Lists

extension UserInfoModel.CountryState {
  
  static let usStates: [UserInfoModel.CountryState] = [
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
  
  static let canadaStates: [UserInfoModel.CountryState] = [
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
  
}

// MARK: - Countries Lists

extension UserInfoModel.Country {
  
  static let countries: [UserInfoModel.Country] = {
    return Locale.isoRegionCodes.map { .init(name: Locale.current.localizedString(forRegionCode: $0) ?? "",
                                             code: $0) }
  }()
  
  static let countryNames: [String] = {
    return Locale.isoRegionCodes.compactMap { Locale.current.localizedString(forRegionCode: $0) }
  }()
  
}
