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
    case id = "account_id"
    case email
    case tags
  }
  
  let id: String
  let email: String?
  let mergedAccounts: [UserDetailTagModel]
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let id = try container.decode(String.self, forKey: .id)
    self.id = id
    self.email = (try container.decodeIfPresent(String.self, forKey: .email))?.toNilIfEmpty()
    let tags = try container.decode([UserDetailTagModel].self, forKey: .tags)
    self.mergedAccounts = tags.filter { $0.accountId == id && $0.namespace == "account_merge" }
  }
  
}

struct UserDetailTagModel: Decodable {
  
  private enum CodingKeys: String, CodingKey {
    case accountId = "account_id"
    case resourceId = "resource_id"
    case namespace
  }
  
  let accountId: String
  let resourceId: String
  let namespace: String
  
}
