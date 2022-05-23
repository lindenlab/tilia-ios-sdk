//
//  UserDocumentsModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.05.2022.
//

import UIKit

struct UserDocumentsModel {
  
  var document: DocumentModel?
  var frontImage: UIImage?
  var backImage: UIImage?
  var documentCountry: String
  var isAddressOnDocument: BoolModel?
  
  var isUsResident: Bool {
    return documentCountry == "USA" // TODO: - Fix me
  }
  
}
