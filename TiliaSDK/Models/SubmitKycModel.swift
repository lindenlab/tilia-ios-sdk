//
//  SubmitKycModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 13.07.2022.
//

import UIKit
import PDFKit

struct SubmitKycModel: Encodable {
  
  private enum CodingKeys: String, CodingKey {
    case userInfo = "kyc_pii"
    case files = "extra_files"
  }
  
  private let userInfo: UserInfo
  private let files: [File]
  
  init(userInfoModel: UserInfoModel, userDocumentsModel: UserDocumentsModel) {
    self.userInfo = UserInfo(userInfoModel: userInfoModel,
                             userDocumentsModel: userDocumentsModel)
    self.files = userDocumentsModel.additionalDocuments.enumerated().map { File(additionalDocument: $0.element,
                                                                                index: $0.offset + 1) }
  }
  
}

// MARK: - Additional Models

private extension SubmitKycModel {
  
  struct UserInfo: Encodable {
    
    private enum CodingKeys: String, CodingKey {
      case country
      case firstName = "first"
      case middleName = "middle"
      case lastName = "last"
      case dateOfBirth = "date_of_birth"
      case street
      case apartment = "street2"
      case city
      case region = "state"
      case postalCode = "zip"
      case canUseAddressFor1099 = "use_1099"
      case ssn
      case signature
      case document = "document_type"
      case documentFront = "document_front"
      case documentBack = "document_back"
      case documentCountry = "document_country"
    }
    
    let country: String
    let firstName: String
    let middleName: String
    let lastName: String
    let dateOfBirth: String
    let street: String
    let apartment: String
    let city: String
    let region: String
    let postalCode: String
    let canUseAddressFor1099: Bool?
    let ssn: String?
    let signature: String?
    let document: String
    let documentFront: String
    let documentBack: String?
    let documentCountry: String
    
    init(userInfoModel: UserInfoModel, userDocumentsModel: UserDocumentsModel) {
      self.country = userInfoModel.countryOfResidence?.code ?? ""
      self.firstName = userInfoModel.fullName.first ?? ""
      self.middleName = userInfoModel.fullName.middle ?? ""
      self.lastName = userInfoModel.fullName.last ?? ""
      self.dateOfBirth = Self.dateOfBirth(for: userInfoModel.dateOfBirth) ?? ""
      self.street = userInfoModel.address.street ?? ""
      self.apartment = userInfoModel.address.apartment ?? ""
      self.city = userInfoModel.address.city ?? ""
      self.region = userInfoModel.address.region.region ?? ""
      self.postalCode = userInfoModel.address.postalCode ?? ""
      self.canUseAddressFor1099 = userInfoModel.canUseAddressFor1099?.boolValue
      self.ssn = userInfoModel.tax?.ssn
      self.signature = userInfoModel.tax?.signature
      self.document = userDocumentsModel.document?.code ?? ""
      self.documentFront = Self.documentBase64EncodedString(for: userDocumentsModel.frontImage) ?? ""
      self.documentBack = Self.documentBase64EncodedString(for: userDocumentsModel.backImage)
      self.documentCountry = userDocumentsModel.documentCountry?.code ?? ""
    }
    
    private static func documentBase64EncodedString(for document: UserDocumentsModel.DocumentImage?) -> String? {
      guard let base64EncodedString = document?.data.base64EncodedString() else { return nil }
      return "data:image/jpg;base64,\(base64EncodedString)"
    }
    
    private static func dateOfBirth(for date: Date?) -> String? {
      guard let date = date else { return nil }
      return date.string(formatter: .customDateFormatter)
    }
  }
  
  struct File: Encodable {
    
    private enum CodingKeys: String, CodingKey {
      case name = "file_name"
      case ext = "file_ext"
      case mimeType = "file_mime_type"
      case content = "file_contents"
    }
    
    let name: String
    let ext: String
    let mimeType: String
    let content: String
    
    init(additionalDocument: UserDocumentsModel.DocumentImage, index: Int) {
      self.name = "my_file_\(String(index))"
      self.ext = additionalDocument.ext
      self.mimeType = additionalDocument.mimeType
      self.content = additionalDocument.data.base64EncodedString()
    }
  }
  
}

// MARK: - Additional Helpers

private extension UserDocumentsModel.Document {
  
  var code: String {
    switch self {
    case .passport: return "PP"
    case .driversLicense: return "DL"
    case .identityCard, .residencePermit: return "ID"
    }
  }
  
}

private extension UserDocumentsModel.DocumentImage {
  
  var ext: String {
    switch type {
    case .pdf: return ".pdf"
    case .image: return ".jpg"
    }
  }
  
  var mimeType: String {
    switch type {
    case .pdf: return "application/pdf"
    case .image: return "img/jpg"
    }
  }
  
}

private extension CountryStateModel {
  
  var region: String? { return code ?? name }
  
}

private extension BoolModel {
  
  var boolValue: Bool {
    switch self {
    case .yes: return true
    case .no: return false
    }
  }
  
}
