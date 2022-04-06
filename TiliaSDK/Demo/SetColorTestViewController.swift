//
//  SetColorTestViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 06.04.2022.
//

import UIKit

class SetColorTestViewController: UIViewController {
  
  let manager: TLManager = TLManager.shared
  
  let lightModeTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.placeholder = "Light mode hex, #ffffff"
    return textField
  }()
  
  let darkModeTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.placeholder = "Dark mode hex, #ffffff"
    return textField
  }()
  
  let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.spacing = 20
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
  
  var lightModeColor: UIColor {
    return UIColor(hexString: lightModeTextField.text ?? "")
  }
  
  var darkModeColor: UIColor {
    return UIColor(hexString: darkModeTextField.text ?? "")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    stackView.addArrangedSubview(lightModeTextField)
    stackView.addArrangedSubview(darkModeTextField)
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
    self.navigationController?.popViewController(animated: true)
  }
  
}
