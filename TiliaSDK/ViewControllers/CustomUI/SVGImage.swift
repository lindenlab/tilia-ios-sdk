//
//  SVGImage.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 06.07.2022.
//

import PocketSVG

final class SVGImage: SVGImageView {
  
  convenience init?(name: String) {
    guard let url = BundleToken.bundle.url(forResource: name, withExtension: "svg") else { return nil }
    self.init(contentsOf: url)
    setupLayersColor()
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
    setupLayersColor()
  }
  
}

// MARK: - Private Methods

private extension SVGImage {
  
  func setupLayersColor() {
    paths.enumerated().forEach { index, path in
      var attributes: [String: Any] = [:]
      if let fillColor = cgColor(from: path.svgAttributes["fill"]), var components = fillColor.components {
        components.removeLast()
        if !isColorWhite(components: components) {
          attributes["fill"] = UIColor.primaryColor.cgColor
        }
      }
      if let strokeColor = cgColor(from: path.svgAttributes["stroke"]), var components = strokeColor.components {
        components.removeLast()
        if !isColorWhite(components: components) {
          attributes["stroke"] = UIColor.primaryColor.cgColor
        }
      }
      if !attributes.isEmpty {
        paths[index] = path.settingSVGAttributes(attributes)
      }
    }
  }
  
  func isColorWhite(components: [CGFloat]) -> Bool {
    return components == [1, 1, 1]
  }
  
  func cgColor(from value: Any?) -> CGColor? {
    guard value != nil else { return nil }
    let ref = value as CFTypeRef
    if CFGetTypeID(ref) == CGColor.typeID {
      return (ref as! CGColor)
    } else {
      return nil
    }
  }
  
}
