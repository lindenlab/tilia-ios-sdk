//
//  TLTosViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.03.2022.
//

import UIKit
import Combine

final class TosViewController: BaseViewController, LoadableProtocol {
  
  var hideableView: UIView { return stackView }
  var spinnerPosition: CGPoint { return stackView.center }
  
  private let viewModel: TosViewModelProtocol
  private let router: TosRoutingProtocol
  private var subscriptions: Set<AnyCancellable> = []
  private var links: [TosAcceptModel] { return TosAcceptModel.allCases }
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.text = L.tiliaTos
    label.numberOfLines = 0
    label.font = UIFont.boldSystemFont(ofSize: 18)
    label.textColor = .primaryTextColor
    return label
  }()
  
  private lazy var acceptSwitch: UISwitch = {
    let uiSwitch = UISwitch()
    uiSwitch.clipsToBounds = true
    uiSwitch.layer.cornerRadius = uiSwitch.frame.height / 2
    uiSwitch.backgroundColor = .borderColor
    uiSwitch.onTintColor = .primaryColor
    uiSwitch.addTarget(self, action: #selector(switchDidChange), for: .valueChanged)
    uiSwitch.accessibilityIdentifier = "acceptSwitch"
    uiSwitch.setContentHuggingPriority(.required, for: .horizontal)
    return uiSwitch
  }()
  
  private lazy var messageTextView: TextViewWithLink = {
    let textView = TextViewWithLink()
    textView.linkDelegate = self
    textView.font = UIFont.systemFont(ofSize: 16)
    textView.textColor = .primaryTextColor
    textView.linkColor = .primaryColor
    let text = TosAcceptModel.title
    let links = self.links.map { $0.description }
    textView.textData = (text, links)
    return textView
  }()
  
  private lazy var buttonsView: ButtonsView = {
    let view = ButtonsView()
    view.primaryButtonText = L.accept
    view.isPrimaryButtonEnabled = acceptSwitch.isOn
    view.primaryButtonAccessibilityIdentifier = "acceptButton"
    view.nonPrimaryButtonText = L.cancel
    view.nonPrimaryButtonAccessibilityIdentifier = "cancelButton"
    view.delegate = self
    return view
  }()
  
  private lazy var stackView: UIStackView = {
    let messageStackView = UIStackView(arrangedSubviews: [acceptSwitch,
                                                          messageTextView])
    messageStackView.alignment = .center
    messageStackView.spacing = 10
    
    let stackView = UIStackView(arrangedSubviews: [titleLabel,
                                                   messageStackView,
                                                   buttonsView])
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  init(manager: NetworkManager,
       onComplete: ((TLCompleteCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    let router = TosRouter()
    self.viewModel = TosViewModel(manager: manager,
                                  onComplete: onComplete,
                                  onError: onError)
    self.router = router
    super.init(nibName: nil, bundle: nil)
    router.viewController = self
    self.presentationController?.delegate = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
  }
  
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension TosViewController: UIAdaptivePresentationControllerDelegate {
  
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    viewModel.complete()
  }
  
}

// MARK: - TextViewWithLinkDelegate

extension TosViewController: TextViewWithLinkDelegate {
  
  func textViewWithLink(_ textView: TextViewWithLink, didPressOn link: String) {
    router.showWebView(with: link)
  }
  
}

// MARK: - ButtonsViewDelegate

extension TosViewController: ButtonsViewDelegate {
  
  func buttonsViewPrimaryButtonDidTap(_ view: ButtonsView) {
    viewModel.acceptTos()
  }
  
  func buttonsViewPrimaryNonButtonDidTap(_ view: ButtonsView) {
    router.dismiss { self.viewModel.complete() }
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
      $0 ? self.startLoading() : self.stopLoading()
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
    buttonsView.isPrimaryButtonEnabled = acceptSwitch.isOn
  }
  
}
