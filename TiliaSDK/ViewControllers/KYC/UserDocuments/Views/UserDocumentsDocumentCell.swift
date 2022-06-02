//
//  UserDocumentsDocumentCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 31.05.2022.
//

import UIKit
import PDFKit

protocol UserDocumentsDocumentCellDelegate: AnyObject {
  func userDocumentsDocumentCellCloseButtonDidTap(_ cell: UserDocumentsDocumentCell)
}

final class UserDocumentsDocumentCell: UICollectionViewCell {
  
  private weak var delegate: UserDocumentsDocumentCellDelegate?
  
  private let pdfView: PDFView = {
    let view = PDFView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    return view
  }()
  
  private let deleteButton: PrimaryButton = {
    let button = PrimaryButton()
    button.setImage(.closeIcon?.withRenderingMode(.alwaysTemplate),
                    for: .normal)
    button.imageView?.tintColor = .primaryButtonTextColor
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    setupBorderColor()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    setupBorderColor()
  }
  
  func configure(document: PDFDocument?, delegate: UserDocumentsDocumentCellDelegate?) {
    self.delegate = delegate
    pdfView.document = document
  }
  
}

private extension UserDocumentsDocumentCell {
  
  func setup() {
    backgroundColor = .backgroundColor
    contentView.backgroundColor = .backgroundColor
    contentView.layer.cornerRadius = 8
    contentView.layer.borderWidth = 1
    
    contentView.addSubview(pdfView)
    contentView.addSubview(deleteButton)
    
    NSLayoutConstraint.activate([
      pdfView.topAnchor.constraint(equalTo: contentView.topAnchor),
      pdfView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
      pdfView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
      pdfView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      deleteButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
      deleteButton.widthAnchor.constraint(equalToConstant: 40),
      deleteButton.heightAnchor.constraint(equalToConstant: 40)
    ])
  }
  
  func setupBorderColor() {
    contentView.layer.borderColor = UIColor.borderColor.cgColor
  }
  
}
