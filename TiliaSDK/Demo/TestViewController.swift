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
    label.numberOfLines = 0
    label.text = "Result will be here"
    return label
  }()
  
  let accessTokenTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.placeholder = "User access token"
    textField.accessibilityIdentifier = "accessTokenTextField"
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
    button.accessibilityIdentifier = "doSmthButton"
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .backgroundColor
    accessTokenTextField.delegate = self
    stackView.addArrangedSubview(accessTokenTextField)
    stackView.addArrangedSubview(label)
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
  
  static func attributedString(text: String, message: String) -> NSAttributedString? {
    guard !text.isEmpty && !message.isEmpty else { return nil }
    let date = Date()
    let dateStr = date.string(formatter: .customDateAndTimeFormatter)
    let str = "\(text):\n\(dateStr)\n\(message)"
    return str.attributedString(font: .systemFont(ofSize: 16),
                                color: .black,
                                subStrings: (text, .systemFont(ofSize: 16), .black), (dateStr, .systemFont(ofSize: 16), .lightGray), (message, .systemFont(ofSize: 16), .lightGray))
  }
  
}

// MARK: - UITextFieldDelegate

extension TestViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
}
