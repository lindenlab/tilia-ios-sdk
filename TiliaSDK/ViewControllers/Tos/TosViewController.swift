//
//  TLTosViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.03.2022.
//

import UIKit
import Combine

final class TosViewController: UIViewController, LoadableProtocol {
  
  var hideableView: UIView { return stackView }
  var spinnerPosition: CGPoint { return stackView.center }
  
  private let viewModel: TosViewModelProtocol
  private let router: TosRoutingProtocol
  private let completion: ((Bool) -> Void)?
  private var subscriptions: Set<AnyCancellable> = []
  private var links: [TosAcceptModel] { return TosAcceptModel.allCases }
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.text = L.tiliaTos
    label.numberOfLines = 0
    label.font = UIFont.boldSystemFont(ofSize: 18)
    label.textColor = .customBlack
    return label
  }()
  
  private lazy var acceptSwitch: UISwitch = {
    let uiSwitch = UISwitch()
    uiSwitch.addTarget(self, action: #selector(switchDidChange), for: .valueChanged)
    return uiSwitch
  }()
  
  private lazy var messageTextView: TextViewWithLink = {
    let textView = TextViewWithLink()
    textView.linkPublisher.sink { [weak self] in
      self?.router.routeToWebView(with: $0)
    }.store(in: &subscriptions)
    let text = TosAcceptModel.title
    let links = self.links.map { $0.description }
    textView.textData = (text, links)
    textView.linkColor = .royalBlue
    textView.textColor = .customBlack
    return textView
  }()
  
  private lazy var acceptButton: FullFilledButton = {
    let button = FullFilledButton()
    button.setTitle(L.accept, for: .normal)
    button.addTarget(self, action: #selector(acceptButtonDidTap), for: .touchUpInside)
    button.isEnabled = acceptSwitch.isOn
    return button
  }()
  
  private lazy var cancelButton: RoundedButton = {
    let button = RoundedButton()
    button.setTitle(L.cancel, for: .normal)
    button.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
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
    stackView.spacing = 20
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
  }
  
  init(completion: ((Bool) -> Void)?) {
    let router = TosRouter()
    self.viewModel = TosViewModel()
    self.router = router
    self.completion = completion
    super.init(nibName: nil, bundle: nil)
    router.viewController = self
    self.presentationController?.delegate = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension TosViewController: UIAdaptivePresentationControllerDelegate {
  
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    completion?(false)
  }
  
}

// MARK: - Private Methods

private extension TosViewController {
  
  func setup() {
    view.backgroundColor = .white
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
    viewModel.accept.sink { [weak self] _ in
      guard let self = self else { return }
      self.router.dismiss() { self.completion?(true) }
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
    router.dismiss { self.completion?(false) }
  }
  
}
