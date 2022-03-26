//
//  TLTosViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.03.2022.
//

import UIKit
import Combine

final public class TLTosViewController: UIViewController {
  
  private let viewModel: TosViewModelProtocol = TosViewModel()
  private var subscriptions: Set<AnyCancellable> = []
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Tilia Terms Of Service"
    label.numberOfLines = 0
    label.textColor = .black
    return label
  }()
  
  private lazy var acceptSwitch: UISwitch = {
    let uiSwitch = UISwitch()
    uiSwitch.translatesAutoresizingMaskIntoConstraints = false
    uiSwitch.addTarget(self, action: #selector(switchDidChange), for: .valueChanged)
    return uiSwitch
  }()
  
  private lazy var messageTextView: TextViewWithLink = {
    let textView = TextViewWithLink()
    textView.linkPublisher.sink {
      print($0)
    }.store(in: &subscriptions)
    textView.translatesAutoresizingMaskIntoConstraints = false
    let text = "I agree to Tilia Inc.'s Terms of Service and acknowledge receipt of Tilia Inc.'s Privacy Policy."
    let links = ["Terms of Service", "Privacy Policy"]
    textView.textData = (text, links)
    return textView
  }()
  
  private lazy var acceptButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Accept", for: .normal)
    button.addTarget(self, action: #selector(acceptButtonDidTap), for: .touchUpInside)
    return button
  }()
  
  private lazy var cancelButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Cancel", for: .normal)
    button.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
    return button
  }()
  
  public init() {
    super.init(nibName: nil, bundle: nil)
    modalPresentationStyle = .fullScreen
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    modalPresentationStyle = .fullScreen
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
}

private extension TLTosViewController {
  
  func setup() {
    view.backgroundColor = .white
    
    let messageStackView = UIStackView(arrangedSubviews: [acceptSwitch,
                                                          messageTextView])
    messageStackView.alignment = .center
    messageStackView.spacing = 10
    
    let stackView = UIStackView(arrangedSubviews: [titleLabel,
                                                   messageStackView,
                                                   acceptButton,
                                                   cancelButton])
    stackView.axis = .vertical
    stackView.spacing = 20
    stackView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stackView)
    
    NSLayoutConstraint.activate([
      stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16)
    ])
  }
  
  @objc func switchDidChange() {
    acceptButton.isEnabled = acceptSwitch.isOn
  }
  
  @objc func acceptButtonDidTap() {
    
  }
  
  @objc func cancelButtonDidTap() {
    if presentingViewController != nil {
      dismiss(animated: true)
    } else if let navigationController = navigationController, navigationController.contains(self) {
      navigationController.popViewController(animated: true)
    }
  }
  
}
