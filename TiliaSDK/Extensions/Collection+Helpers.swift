//
//  Collection+Helpers.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 03.10.2022.
//

import Foundation

extension Collection {
  
  func element(at index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
  
  subscript(safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }

}
