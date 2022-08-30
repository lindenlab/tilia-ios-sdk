//
//  InvoiceInfoModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 29.08.2022.
//

import Foundation

struct InvoiceInfoModel {
  
  let currency: String
  let referenceType: String
  let referenceId: String
  let displayAmount: String
  let items: [LineItemModel]
  
}
