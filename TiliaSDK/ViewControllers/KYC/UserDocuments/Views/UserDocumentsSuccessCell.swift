//
//  UserDocumentsSuccessCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 07.06.2022.
//

import UIKit
import Lottie

final class UserDocumentsSuccessCell: UITableViewCell {
  
  private let animationView: AnimationView = {
    let view = AnimationView(animation: .successAnimation)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .backgroundColor
    return view
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func startAnimatingIfNeeded() {
    guard !animationView.isAnimationPlaying else { return }
    animationView.play()
  }
  
}

// MARK: - Private Methods

private extension UserDocumentsSuccessCell {
  
  func setup() {
    selectionStyle = .none
    contentView.addSubview(animationView)
    
    let bottomAnchor = animationView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    bottomAnchor.priority = UILayoutPriority(999)
    
    NSLayoutConstraint.activate([
      animationView.topAnchor.constraint(equalTo: contentView.topAnchor),
      animationView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
      animationView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
      bottomAnchor,
      animationView.heightAnchor.constraint(equalTo: animationView.widthAnchor, multiplier: 0.7)
    ])
  }
  
}
