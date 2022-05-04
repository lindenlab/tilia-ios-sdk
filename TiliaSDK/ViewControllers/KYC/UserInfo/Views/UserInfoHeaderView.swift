//
//  UserInfoHeaderView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 04.05.2022.
//

import UIKit

protocol UserInfoHeaderViewDelegate: AnyObject {
  func userInfoHeaderView(didSelect isSelected: Bool)
}

final class UserInfoHeaderView: UITableViewHeaderFooterView {
  
  private weak var delegate: UserInfoHeaderViewDelegate?
  
  private lazy var selectableView: SelectableView = {
    let view = SelectableView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.addTarget(self, action: #selector(didSelect), for: .valueChanged)
    return view
  }()
  
  func configure(title: String,
                 mode: SelectableView.Mode,
                 delegate: UserInfoHeaderViewDelegate?) {
    selectableView.mode = mode
    selectableView.title = title
    self.delegate = delegate
  }
  
}

// MARK: - Private Methods

private extension UserInfoHeaderView {
  
  func setup() {
    contentView.backgroundColor = .clear
    contentView.addSubview(selectableView)
    
    let topConstraint = selectableView.topAnchor.constraint(equalTo: contentView.topAnchor)
    topConstraint.priority = UILayoutPriority(999)
    NSLayoutConstraint.activate([
      topConstraint,
      selectableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      selectableView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
      selectableView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
    ])
  }
  
  @objc func didSelect() {
    
  }
  
}
