//
//  SetColorsTestViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 06.04.2022.
//

import UIKit

final class SetColorsTestView: UIView {
  
  let label = UILabel()
  
  let lightModeTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.placeholder = "Light mode hex"
    return textField
  }()
  
  let darkModeTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.placeholder = "Dark mode hex"
    return textField
  }()
  
  var lightModeColor: UIColor {
    return UIColor(hexString: lightModeTextField.text ?? "")
  }
  
  var darkModeColor: UIColor {
    return UIColor(hexString: darkModeTextField.text ?? "")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    let fieldsStackView = UIStackView(arrangedSubviews: [lightModeTextField, darkModeTextField])
    fieldsStackView.spacing = 2
    fieldsStackView.distribution = .fillEqually
    
    let stackView = UIStackView(arrangedSubviews: [label, fieldsStackView])
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.spacing = 5
    
    addSubview(stackView)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor),
      stackView.leftAnchor.constraint(equalTo: leftAnchor),
      stackView.rightAnchor.constraint(equalTo: rightAnchor),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

final class SetColorsTestViewController: UIViewController {
  
  let manager: TLManager = TLManager.shared
  
  let backgroundColorView: SetColorsTestView = {
    let view = SetColorsTestView()
    view.label.text = "Set backgroundColor"
    return view
  }()
  
  let primaryColorView: SetColorsTestView = {
    let view = SetColorsTestView()
    view.label.text = "Set primaryColor"
    return view
  }()
  
  let primaryTextColorView: SetColorsTestView = {
    let view = SetColorsTestView()
    view.label.text = "Set primaryTextColor"
    return view
  }()
  
  let successBackgroundColorView: SetColorsTestView = {
    let view = SetColorsTestView()
    view.label.text = "Set successBackgroundColor"
    return view
  }()
  
  let failureBackgroundColorView: SetColorsTestView = {
    let view = SetColorsTestView()
    view.label.text = "Set failureBackgroundColor"
    return view
  }()
  
  lazy var stackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [
      backgroundColorView,
      primaryColorView,
      primaryTextColorView,
      successBackgroundColorView,
      failureBackgroundColorView
    ])
    stackView.spacing = 5
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  let button: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("SET COLORS", for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    view.addSubview(stackView)
    view.addSubview(button)
    button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    NSLayoutConstraint.activate([
      stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
      stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      button.heightAnchor.constraint(equalToConstant: 50),
      button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
      button.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
      button.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16)
    ])
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    view.endEditing(true)
  }
  
  @objc func buttonTapped() {
    manager.setBackgroundColor(forLightMode: backgroundColorView.lightModeColor, andDarkMode: backgroundColorView.darkModeColor)
    manager.setPrimaryColor(forLightMode: primaryColorView.lightModeColor, andDarkMode: primaryColorView.darkModeColor)
    // TODO: - Temporary removed
//    manager.setPrimaryTextColor(forLightMode: primaryTextColorView.lightModeColor, andDarkMode: primaryTextColorView.darkModeColor)
    manager.setSuccessBackgroundColor(forLightMode: successBackgroundColorView.lightModeColor, andDarkMode: successBackgroundColorView.darkModeColor)
    manager.setFailureBackgroundColor(forLightMode: failureBackgroundColorView.lightModeColor, andDarkMode: failureBackgroundColorView.darkModeColor)
    self.navigationController?.popViewController(animated: true)
  }
  
}
