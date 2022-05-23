//
//  DocumentModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.05.2022.
//

import Foundation

enum DocumentModel: CustomStringConvertible, CaseIterable {
  
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
    case DocumentModel.passport.description: self = .passport
    case DocumentModel.driversLicense.description: self = .driversLicense
    case DocumentModel.identityCard.description: self = .identityCard
    case DocumentModel.residencePermit.description: self = .residencePermit
    default: return nil
    }
  }
  
}
