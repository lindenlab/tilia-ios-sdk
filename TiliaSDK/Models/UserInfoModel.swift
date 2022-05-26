//
//  UserInfoModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 07.05.2022.
//

import Foundation

struct UserInfoModel {
  
  struct FullName {
    var first: String?
    var middle: String?
    var last: String?
  }
  
  struct Address {
    var street: String?
    var apartment: String?
    var city: String?
    var region: String?
    var postalCode: String?
  }
  
  struct Tax {
    var ssn: String?
    var signature: String?
  }
  
  var countryOfResidence: String?
  var fullName: FullName
  var dateOfBirth: Date?
  var address: Address
  var canUseAddressFor1099: BoolModel?
  var tax: Tax
  
  var isUsResident: Bool {
    return countryOfResidence == "USA" // TODO: - Fix me
  }
  
  var dateOfBirthString: String? {
    return dateOfBirth.map { $0.string() }
  }
  
  init(countryOfResidence: String? = nil,
       fullName: FullName = FullName(),
       dateOfBirth: Date? = nil,
       address: Address = Address(),
       canUseAddressFor1099: BoolModel? = nil,
       tax: Tax = Tax()) {
    self.countryOfResidence = countryOfResidence
    self.fullName = fullName
    self.dateOfBirth = dateOfBirth
    self.address = address
    self.canUseAddressFor1099 = canUseAddressFor1099
    self.tax = tax
  }
  
  mutating func setAddressToDefault() {
    address.street = nil
    address.apartment = nil
    address.city = nil
    address.region = nil
    address.postalCode = nil
    canUseAddressFor1099 = nil
  }
  
  mutating func setTaxToDefault() {
    tax.ssn = nil
    tax.signature = nil
  }
  
}
