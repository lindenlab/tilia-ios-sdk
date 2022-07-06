//
//  SVGImage.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 06.07.2022.
//

import PocketSVG

final class SVGImage: SVGImageView {
  
  var uiImage: UIImage {
    let size = CGSize(width: viewBox.size.width + 2,
                      height: viewBox.size.height + 2)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { return layer.render(in: $0.cgContext) }
  }
  
  convenience init?(name: String) {
    guard let url = BundleToken.bundle.url(forResource: name, withExtension: "svg") else { return nil }
    self.init(contentsOf: url)
    frame = viewBox
    layer.layoutIfNeeded()
    setupLayersColor()
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    setupLayersColor()
  }
  
}

private extension SVGImage {
  
  func setupLayersColor() {
    guard let layers = layer.sublayers?.compactMap({ $0 as? CAShapeLayer }) else { return }
    layers.forEach { layer in
      if let fillColor = layer.fillColor, var components = fillColor.components {
        components.removeLast()
        if components != [1, 1, 1] {
          layer.fillColor = UIColor.primaryColor.cgColor
        }
      }
      if let strokeColor = layer.strokeColor, var components = strokeColor.components {
        components.removeLast()
        if components != [1, 1, 1] {
          layer.strokeColor = UIColor.primaryColor.cgColor
        }
      }
    }
  }
  
}
