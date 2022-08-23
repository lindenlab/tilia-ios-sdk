//
//  TransactionDetailsSectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 22.08.2022.
//

import UIKit

struct TransactionDetailsSectionBuilder {
  
  struct Header {
    
    struct Status {
      let image: UIImage?
      let title: String
      let subTitle: String?
    }
    
    let image: UIImage?
    let title: NSAttributedString
    let subTitle: String
    let status: Status?
  }
  
  struct Content {
    let title: String
  }
  
  struct Item {
    
  }
  
  enum Section {
    case header(Header)
    case content(Content)
  }
  
  
  
}
