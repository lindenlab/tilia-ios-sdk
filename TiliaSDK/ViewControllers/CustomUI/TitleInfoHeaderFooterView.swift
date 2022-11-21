//
//  TitleInfoHeaderFooterView.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 02.05.2022.
//

import UIKit

final class TitleInfoHeaderFooterView: UITableViewHeaderFooterView {
  
  private let titleInfoView: TitleInfoView = {
    let view = TitleInfoView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.subTitleTextFont = .systemFont(ofSize: 14)
    return view
  }()
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(title: String,
                 subTitle: String?,
                 subTitleTextColor: UIColor = .secondaryTextColor,
                 spacing: CGFloat = 8) {
    titleInfoView.title = title
    titleInfoView.subTitle = subTitle
    titleInfoView.subTitleTextColor = subTitleTextColor
    titleInfoView.spacing = spacing
  }
  
}

// MARK: - Private Methods

private extension TitleInfoHeaderFooterView {
  
  func setup() {
    contentView.backgroundColor = .backgroundColor
    contentView.addSubview(titleInfoView)
    
    let topConstraint = titleInfoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16)
    topConstraint.priority = UILayoutPriority(999)
    NSLayoutConstraint.activate([
      topConstraint,
      titleInfoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
      titleInfoView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
      titleInfoView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
    ])
  }
  
}
