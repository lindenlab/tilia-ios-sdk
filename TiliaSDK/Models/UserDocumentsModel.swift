//
//  UserDocumentsModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.05.2022.
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
  
  struct Image {
    let image: UIImage
    let title: String
  }
  
  var document: Document?
  var frontImage: Image?
  var backImage: Image?
  var documentCountry: String
  var isAddressOnDocument: BoolModel?
  
  var isUsResident: Bool {
    return documentCountry == "USA" // TODO: - Fix me
  }
  
}
