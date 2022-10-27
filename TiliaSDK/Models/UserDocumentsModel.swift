//
//  UserDocumentsModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 13.07.2022.
//

import UIKit

struct UserDocumentsModel {
  
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
  
  struct DocumentImage {
    
    enum DocumentImageType {
      case pdf
      case image
    }
    
    let image: UIImage
    let data: Data
    let type: DocumentImageType
  }
  
  var document: Document?
  var frontImage: DocumentImage?
  var backImage: DocumentImage?
  var documentCountry: CountryModel?
  var isAddressOnDocument: BoolModel?
  var additionalDocuments: [DocumentImage] = []
  
  var isUsDocumentCountry: Bool { return documentCountry?.isUs == true }
  
  mutating func setDocumentImagesToDefault() {
    frontImage = nil
    backImage = nil
  }
  
}
