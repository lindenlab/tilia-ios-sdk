//
//  UserDetailInfoModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 15.05.2023.
//

import Foundation

protocol EmailVerifiable {
  var email: String? { get }
}

extension EmailVerifiable {
  
  var isEmailVerified: Bool { return !email.isEmpty }
  
}

struct UserDetailInfoModel: Decodable, EmailVerifiable {
  
  private enum CodingKeys: String, CodingKey {
    case email
  }
  
  let email: String?
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.email = (try container.decodeIfPresent(String.self, forKey: .email))?.toNilIfEmpty()
  }
  
}
