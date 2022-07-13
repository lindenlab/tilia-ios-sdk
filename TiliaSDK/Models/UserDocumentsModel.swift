//
//  UserDocumentsModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 13.07.2022.
//

import UIKit
import PDFKit

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
  
  enum AdditionalDocument {
    case pdfFile(PDFDocument)
    case image(UIImage)
  }
  
  var document: Document?
  var frontImage: UIImage?
  var backImage: UIImage?
  var documentCountry: CountryModel?
  var isAddressOnDocument: BoolModel?
  var additionalDocuments: [AdditionalDocument] = []
  
  var isUsDocumentCountry: Bool { return documentCountry?.isUs == true }
  
  mutating func setDocumentImagesToDefault() {
    frontImage = nil
    backImage = nil
  }
  
}
