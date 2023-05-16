//
//  UserDetailInfoModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 15.05.2023.
//

import Foundation

struct UserDetailInfoModel: Decodable {
  
  let email: String?
  
  var needVerifyEmail: Bool { return email == nil }
  
}
