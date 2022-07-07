//
//  AddCreditCardViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 21.04.2022.
//

import UIKit
import Combine

final class AddCreditCardViewController: BaseViewController {
  
  override var hideableView: UIView {
    return stackView
  }
  
  private let viewModel: AddCreditCardViewModelProtocol
  private let router: AddCreditCardRoutingProtocol
  private var subscriptions: Set<AnyCancellable> = []
  
  private let titleInfoView: TitleInfoView = {
    let view = TitleInfoView()
    view.title = L.addCreditCardTitle
    view.subTitle = L.addCreditCardMessage
    return view
  }()
  
  private lazy var openBrowserButton: PrimaryButton = {
    let button = PrimaryButton()
    button.setTitle(L.openBrowser, for: .normal)
    button.addTarget(self, action: #selector(openBrowserButtonDidTap), for: .touchUpInside)
    button.accessibilityIdentifier = "openBrowserButton"
    return button
  }()
  
  private lazy var doneButton: NonPrimaryButton = {
    let button = NonPrimaryButton()
    button.setTitle(L.done, for: .normal)
    button.addTarget(self, action: #selector(doneButtonDidTap), for: .touchUpInside)
    button.accessibilityIdentifier = "doneButton"
    return button
  }()
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [titleInfoView,
                                                   openBrowserButton,
                                                   doneButton])
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.setCustomSpacing(32, after: titleInfoView)
    return stackView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
  }
  
  init(manager: NetworkManager,
       onReload: @escaping (Bool) -> Void,
       onError: ((TLErrorCallback) -> Void)?) {
    let router = AddCreditCardRouter()
    self.viewModel = AddCreditCardViewModel(manager: manager,
                                            onReload: onReload,
                                            onError: onError)
    self.router = router
    super.init(nibName: nil, bundle: nil)
    router.viewController = self
    self.presentationController?.delegate = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension AddCreditCardViewController: UIAdaptivePresentationControllerDelegate {
  
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    viewModel.complete()
  }
  
}

// MARK: - Private Methods

private extension AddCreditCardViewController {
  
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
    
    viewModel.error.sink { [weak self] _ in
      self?.router.showToast(title: L.errorAddCreditTitle,
                             message: L.errorAddCreditMessage)
    }.store(in: &subscriptions)
    
    viewModel.openUrl.sink { [weak self] in
      self?.router.showWebView(with: $0)
    }.store(in: &subscriptions)
  }
  
  @objc func openBrowserButtonDidTap() {
    viewModel.openBrowser()
  }
  
  @objc func doneButtonDidTap() {
    router.dismiss { self.viewModel.complete() }
  }
  
}
