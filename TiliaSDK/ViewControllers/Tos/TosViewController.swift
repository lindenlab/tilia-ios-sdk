//
//  TLTosViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.03.2022.
//

import UIKit
import Combine

final class TosViewController: UIViewController {
  
  private let viewModel: TosViewModelProtocol = TosViewModel()
  private lazy var router: TosRoutingProtocol = {
    let router = TosRouter()
    router.viewController = self
    return router
  }()
  private var subscriptions: Set<AnyCancellable> = []
  private var links: [TosAcceptModel] { return TosAcceptModel.allCases }
  
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
    textView.linkPublisher.sink { [weak self] in
      self?.router.routeToWebView(with: $0)
    }.store(in: &subscriptions)
    textView.translatesAutoresizingMaskIntoConstraints = false
    let text = TosAcceptModel.title
    let links = self.links.map { $0.rawValue }
    textView.textData = (text, links)
    return textView
  }()
  
  private lazy var acceptButton: ButtonWithSpinner = {
    let button = ButtonWithSpinner(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Accept", for: .normal)
    button.addTarget(self, action: #selector(acceptButtonDidTap), for: .touchUpInside)
    button.isEnabled = false
    return button
  }()
  
  private lazy var cancelButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Cancel", for: .normal)
    button.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
    return button
  }()
  
  init() {
    super.init(nibName: nil, bundle: nil)
    modalPresentationStyle = .fullScreen
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    modalPresentationStyle = .fullScreen
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
  }
  
}

private extension TosViewController {
  
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
  
  func bind() {
    viewModel.loading.sink { [weak self] in
      guard let self = self else { return }
      self.acceptButton.isLoading = $0
      self.acceptButton.isEnabled = self.acceptSwitch.isOn
    }.store(in: &subscriptions)
    viewModel.accept.sink { [weak self] _ in
      self?.router.dismiss(animated: true, completion: nil)
    }.store(in: &subscriptions)
    viewModel.error.sink { [weak self] in
      self?.router.showAlert(title: $0.localizedDescription)
    }.store(in: &subscriptions)
  }
  
  @objc func switchDidChange() {
    acceptButton.isEnabled = acceptSwitch.isOn
  }
  
  @objc func acceptButtonDidTap() {
    viewModel.acceptTos()
  }
  
  @objc func cancelButtonDidTap() {
    router.dismiss(animated: true, completion: nil)
  }
  
}
