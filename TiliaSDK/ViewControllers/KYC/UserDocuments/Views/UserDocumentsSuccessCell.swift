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
    setupColors()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    setupColors()
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
  
  func setupColors() {
    // Main circle
    animationView.setValueProvider(ColorValueProvider(UIColor.blue.lottieColorValue),
                                   keypath: .init(keypath: "instance:precomp_1.sparkles-1.sparkles-1 shape group.Layer.Color"))
    animationView.setValueProvider(ColorValueProvider(UIColor.blue.lottieColorValue),
                                   keypath: .init(keypath: "instance:precomp_1.ring-01.ring-01 shape group.Layer.Color"))
    
    // Stars
    animationView.setValueProvider(ColorValueProvider(UIColor.yellow.lottieColorValue),
                                   keypath: .init(keypath: "instance:precomp_1.sparkles-2.sparkles-2 shape group.Layer.Color"))
    animationView.setValueProvider(ColorValueProvider(UIColor.yellow.lottieColorValue),
                                   keypath: .init(keypath: "instance:precomp_1.sparkles-3.sparkles-3 shape group.Layer.Color"))
    
    // Small circles
    animationView.setValueProvider(ColorValueProvider(UIColor.green.lottieColorValue),
                                   keypath: .init(keypath: "instance:precomp_1.sparkles-4.sparkles-4 shape group.Layer.Color"))
    animationView.setValueProvider(ColorValueProvider(UIColor.green.lottieColorValue),
                                   keypath: .init(keypath: "instance:precomp_1.sparkles-5.sparkles-5 shape group.Layer.Color"))
    
    // Diamonds
    animationView.setValueProvider(ColorValueProvider(UIColor.red.lottieColorValue),
                                   keypath: .init(keypath: "instance:precomp_1.sparkles-6.sparkles-6 shape group.Layer.Color"))
    animationView.setValueProvider(ColorValueProvider(UIColor.red.lottieColorValue),
                                   keypath: .init(keypath: "instance:precomp_1.sparkles-7.sparkles-7 shape group.Layer.Color"))
    
    
  }
  
}
