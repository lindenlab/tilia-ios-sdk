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
  
  var countryOfResidence: String?
  var fullName: FullName
  var dateOfBirth: Date?
  var ssn: String?
  var address: Address
  var canUseAddressFor1099: BoolModel?
  
  var isUsResident: Bool {
    return countryOfResidence == "USA" // TODO: - Fix me
  }
  
  var dateOfBirthString: String? {
    return dateOfBirth.map { $0.string() }
  }
  
  init(countryOfResidence: String? = nil,
       fullName: FullName = FullName(),
       dateOfBirth: Date? = nil,
       ssn: String? = nil,
       address: Address = Address(),
       canUseAddressFor1099: BoolModel? = nil) {
    self.countryOfResidence = countryOfResidence
    self.fullName = fullName
    self.dateOfBirth = dateOfBirth
    self.ssn = ssn
    self.address = address
    self.canUseAddressFor1099 = canUseAddressFor1099
  }
  
  mutating func setAddressToDefault() {
    address.street = nil
    address.apartment = nil
    address.city = nil
    address.region = nil
    address.postalCode = nil
    canUseAddressFor1099 = nil
  }
  
}
