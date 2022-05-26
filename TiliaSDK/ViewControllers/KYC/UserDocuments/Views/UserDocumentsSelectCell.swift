//
//  UserDocumentsSelectCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 26.05.2022.
//

import UIKit

final class UserDocumentsSelectCell: LabelCell {
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Private Methods

private extension UserDocumentsSelectCell {
  
  func setup() {
    configure(title: L.supportingDocuments,
              font: .boldSystemFont(ofSize: 16))
    configure(description: L.supportingDocumentsDescription,
              font: .systemFont(ofSize: 14))
  }
  
}
