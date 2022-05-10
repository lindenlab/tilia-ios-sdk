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
  
  enum CanUseAddressFor1099: String, CaseIterable {
    case yes = "Yes"
    case no = "No"
  }
  
  var countryOfResidence: String?
  var fullName: FullName
  var dateOfBirth: Date?
  var ssn: String?
  var address: Address
  var canUseAddressFor1099: CanUseAddressFor1099?
  
  var isUsResident: Bool {
    return true
  }
  
  var dateOfBirthString: String? {
    return dateOfBirth.map { $0.string() }
  }
  
  init(countryOfResidence: String? = nil,
       fullName: FullName = FullName(),
       dateOfBirth: Date? = nil,
       ssn: String? = nil,
       address: Address = Address(),
       canUseAddressFor1099: CanUseAddressFor1099? = nil) {
    self.countryOfResidence = countryOfResidence
    self.fullName = fullName
    self.dateOfBirth = dateOfBirth
    self.ssn = ssn
    self.address = address
    self.canUseAddressFor1099 = canUseAddressFor1099
  }
  
}
