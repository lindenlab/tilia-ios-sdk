//
//  BoolModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 13.07.2022.
//

import Foundation


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
