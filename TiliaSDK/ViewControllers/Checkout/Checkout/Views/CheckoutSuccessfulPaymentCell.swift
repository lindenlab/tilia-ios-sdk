//
//  CheckoutSuccessfulPaymentCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 02.04.2022.
//

import UIKit

final class CheckoutSuccessfulPaymentCell: UITableViewCell {
  
  private let toastView: ToastView = {
    let view = ToastView(isSuccess: true)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.configure(title: L.success, message: L.paymentProcessed)
    return view
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Private Methods

private extension CheckoutSuccessfulPaymentCell {
  
  func setup() {
    backgroundColor = .backgroundColor
    contentView.backgroundColor = .backgroundColor
    contentView.addSubview(toastView)
    
    NSLayoutConstraint.activate([
      toastView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      toastView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      toastView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
      toastView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
    ])
  }
  
}
