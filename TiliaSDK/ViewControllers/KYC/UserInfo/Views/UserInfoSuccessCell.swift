//
//  UserInfoSuccessCell.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 07.06.2022.
//

import UIKit
import Lottie

final class UserInfoSuccessCell: UITableViewCell {
  
  private let animationView: AnimationView = {
    let view = AnimationView(animation: .successAnimation)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .backgroundColor
    return view
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
    setupColors()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
    setupColors()
  }
  
  func startAnimatingIfNeeded() {
    guard !animationView.isAnimationPlaying else { return }
    animationView.play()
  }
  
}

// MARK: - Private Methods

private extension UserInfoSuccessCell {
  
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
  
  func setupColors() {
    animationView.setValueProvider(ColorValueProvider(UIColor.primaryColor.lottieColorValue),
                                   keypath: .init(keypath: "Shape Layer 1.Ellipse 1.Fill 1.Color"))
    animationView.setValueProvider(ColorValueProvider(UIColor.primaryColor.lottieColorValue),
                                   keypath: .init(keypath: "**.Shape Layer 1.Shape 1.Stroke 1.Color"))
  }
  
}
