//
//  TLPaymentMethods.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 25.05.2023.
//

import Foundation

public struct TLPaymentMethods: Encodable, CustomStringConvertible {
  
  public let paymentMethods: [TLPaymentMethod]
  
  public var description: String {
    return jsonStr ?? ""
  }
  
}

public struct TLPaymentMethod: Encodable {
  
  public let id: String
  public let amount: Double
  
}
