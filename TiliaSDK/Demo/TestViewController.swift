//
//  TestViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 28.03.2022.
//

import UIKit

class TestViewController: UIViewController {
  
  let manager: TLManager = TLManager.shared
  
  let label: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 18)
    label.numberOfLines = 0
    label.text = "Result will be here"
    return label
  }()
  
  let accessTokenTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.placeholder = "Access token"
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
    button.setTitle("DO SMTH", for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    stackView.addArrangedSubview(label)
    stackView.addArrangedSubview(accessTokenTextField)
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
    label.text = "Loading...."
    manager.setToken(accessTokenTextField.text ?? "")
  }
  
}
