//
//  RedirectUrlModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 24.06.2022.
//

import Foundation

struct RedirectUrlModel: Decodable {
  
  let url: URL
  
  private enum CodingKeys: String, CodingKey {
    case url = "redirect"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let urlStr = try container.decode(String.self, forKey: .url)
    if let url = URL(string: urlStr) {
      self.url = url
    } else {
      throw TLError.urlDoesNotExistForString(urlStr)
    }
  }
  
}
