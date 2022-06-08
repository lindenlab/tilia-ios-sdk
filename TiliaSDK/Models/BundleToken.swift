//
//  BundleToken.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 27.05.2022.
//

import Foundation

final class BundleToken {
  
  static let bundle: Bundle = {
    let frameworkBundle = Bundle(for: BundleToken.self)
    guard let url = frameworkBundle.resourceURL?.appendingPathComponent("TiliaSDK.bundle")
        else { fatalError("Failed to get bundle URL") }
    if let bundle = Bundle(url: url) {
      return bundle
    } else {
      return .main
    }
  }()
  
}
