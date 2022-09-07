//
//  UserInfoModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 07.05.2022.
//

import Foundation

struct UserInfoModel {
  
  struct FullName: PossiblyEmpty {
    var first: String?
    var middle: String?
    var last: String?
    
    var isEmpty: Bool {
      return first.isEmpty || last.isEmpty
    }
  }
  
  struct Address: PossiblyEmpty {
    var street: String?
    var apartment: String?
    var city: String?
    var region: CountryStateModel
    var postalCode: String?
    
    var isEmpty: Bool {
      return street.isEmpty || city.isEmpty || region.isEmpty || postalCode.isEmpty
    }
  }
  
  struct Tax: PossiblyEmpty {
    var ssn: String?
    var signature: String?
    
    var isEmpty: Bool { return ssn.isEmpty || signature.isEmpty }
  }
  
  var countryOfResidence: CountryModel?
  var fullName: FullName = FullName()
  var dateOfBirth: Date?
  var address: Address = Address(region: CountryStateModel())
  var canUseAddressFor1099: BoolModel?
  var tax: Tax?
  
  var isUsResident: Bool { return countryOfResidence?.isUs == true }
  var dateOfBirthString: String? { return dateOfBirth.map { $0.string() } }
  var needDocuments: Bool { return !isUsResident || address.region.isArizonaOrFlorida }
  
  mutating func setAddressToDefault() {
    address.street = nil
    address.apartment = nil
    address.city = nil
    address.region.name = nil
    address.postalCode = nil
    canUseAddressFor1099 = nil
  }
  
}
