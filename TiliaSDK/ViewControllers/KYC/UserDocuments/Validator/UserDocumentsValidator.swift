//
//  UserDocumentsValidator.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 06.06.2022.
//

import Foundation

enum UserDocumentsValidator {
  
  static func isFilled(for model: UserDocumentsModel) -> Bool {
    let isPhotosFilled = model.document == .passport ? model.frontImage != nil : model.frontImage != nil && model.backImage != nil
    let isAdditionalDocumentsFilled = model.isAddressOnDocument == .yes ? true : !model.additionalDocuments.isEmpty
    return isPhotosFilled && isAdditionalDocumentsFilled
  }
  
}
