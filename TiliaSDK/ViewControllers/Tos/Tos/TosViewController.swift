//
//  TLTosViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.03.2022.
//

import UIKit
import Combine

final class TosViewController: BaseViewController {
  
  private let viewModel: TosViewModelProtocol
  private let router: TosRoutingProtocol
  private var subscriptions: Set<AnyCancellable> = []
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.text = L.tiliaTos
    label.numberOfLines = 0
    label.font = .boldSystemFont(ofSize: 20)
    label.textColor = .primaryTextColor
    return label
  }()
  
  private lazy var acceptSwitch: Switch = {
    let uiSwitch = Switch()
    uiSwitch.addTarget(self, action: #selector(switchDidChange), for: .valueChanged)
    uiSwitch.accessibilityIdentifier = "acceptSwitch"
    return uiSwitch
  }()
  
  private lazy var messageTextView: TextViewWithLink = {
    let textView = TextViewWithLink()
    textView.linkDelegate = self
    textView.font = .systemFont(ofSize: 16)
    textView.textColor = .primaryTextColor
    let text = TosAcceptModel.title
    let links = TosAcceptModel.allCases.map { $0.description }
    textView.textData = (text, links)
    return textView
  }()
  
  private lazy var acceptButton: PrimaryButton = {
    let button = PrimaryButton()
    button.setTitle(L.accept, for: .normal)
    button.setTitleForLoadingState(L.accepting)
    button.addTarget(self, action: #selector(acceptButtonDidTap), for: .touchUpInside)
    button.isEnabled = acceptSwitch.isOn
    button.accessibilityIdentifier = "acceptButton"
    return button
  }()
  
  private lazy var cancelButton: NonPrimaryButton = {
    let button = NonPrimaryButton()
    button.setTitle(L.cancel, for: .normal)
    button.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
    button.accessibilityIdentifier = "cancelButton"
    return button
  }()
  
  private lazy var stackView: UIStackView = {
    let messageStackView = UIStackView(arrangedSubviews: [acceptSwitch,
                                                          messageTextView])
    messageStackView.alignment = .center
    messageStackView.spacing = 10
    
    let stackView = UIStackView(arrangedSubviews: [titleLabel,
                                                   messageStackView,
                                                   acceptButton,
                                                   cancelButton])
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  init(manager: NetworkManager,
       onComplete: ((TLCompleteCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    let viewModel = TosViewModel(manager: manager,
                                 onComplete: onComplete,
                                 onError: onError)
    let router = TosRouter(dataStore: viewModel)
    self.viewModel = viewModel
    self.router = router
    super.init()
    router.viewController = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
  }
  
  override func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    viewModel.complete()
  }
  
}

// MARK: - TextViewWithLinkDelegate

extension TosViewController: TextViewWithLinkDelegate {
  
  func textViewWithLink(_ textView: TextViewWithLink, didPressOn link: String) {
    guard let model = TosAcceptModel(str: link) else { return }
    switch model {
    case .termsOfService:
      router.routeToTosContentView()
    case .privacyPolicy:
      router.showWebView(with: TosAcceptModel.privacyPolicyUrl)
    }
  }
  
}

// MARK: - Private Methods

private extension TosViewController {
  
  func setup() {
    view.addSubview(stackView)
    
    NSLayoutConstraint.activate([
      stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16)
    ])
  }
  
  func bind() {
    viewModel.loading.sink { [weak self] in
      guard let self = self else { return }
      self.acceptButton.isLoading = $0
      self.acceptSwitch.isUserInteractionEnabled = !$0
      self.messageTextView.isUserInteractionEnabled = !$0
    }.store(in: &subscriptions)
    
    viewModel.accept.sink { [weak self] in
      guard let self = self, $0 else { return }
      self.router.dismiss { self.viewModel.complete() }
    }.store(in: &subscriptions)
    
    viewModel.error.sink { [weak self] _ in
      self?.router.showToast(title: L.errorTosTitle,
                             message: L.errorTosMessage)
    }.store(in: &subscriptions)
  }
  
  @objc func switchDidChange() {
    acceptButton.isEnabled = acceptSwitch.isOn
  }
  
  @objc func acceptButtonDidTap() {
    viewModel.acceptTos()
  }
  
  @objc func cancelButtonDidTap() {
    router.dismiss { self.viewModel.complete() }
  }
  
}
