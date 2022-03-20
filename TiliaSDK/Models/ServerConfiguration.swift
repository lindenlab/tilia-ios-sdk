//
//  ServerConfiguration.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Foundation

struct ServerConfiguration {
  
  var token: String?
  var timeoutInterval: Double
  var environment: TLEnvironment
  
  init(token: String? = nil,
       timeoutInterval: Double = 30,
       environment: TLEnvironment = .staging) {
    self.token = token
    self.timeoutInterval = timeoutInterval
    self.environment = environment
  }
  
}
