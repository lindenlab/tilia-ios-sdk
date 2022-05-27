//
//  ServerConfiguration.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import Foundation

final class ServerConfiguration {
  
  var token: String?
  var timeoutInterval: Double
  var environment: TLEnvironment
  
  init(token: String?, timeoutInterval: Double, environment: TLEnvironment) {
    self.token = token
    self.timeoutInterval = timeoutInterval
    self.environment = environment
  }
  
}
