//
//  AddPaymentMethodViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 21.04.2022.
//

import UIKit
import Combine

final class AddPaymentMethodViewController: BaseViewController {
  
  private let viewModel: AddPaymentMethodViewModelProtocol
  private let router: AddPaymentMethodRoutingProtocol
  private var subscriptions: Set<AnyCancellable> = []
  
  private lazy var titleInfoView: TitleInfoView = {
    let view = TitleInfoView()
    view.title = viewModel.mode.title
    view.subTitle = viewModel.mode.message
    return view
  }()
  
  private lazy var openBrowserButton: PrimaryButton = {
    let button = PrimaryButton()
    button.setTitle(L.openBrowser, for: .normal)
    button.setTitleForLoadingState(L.opening)
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
       mode: AddPaymentMethodMode,
       onReload: @escaping () -> Void,
       onError: ((TLErrorCallback) -> Void)?) {
    let router = AddPaymentMethodRouter()
    self.viewModel = AddPaymentMethodViewModel(manager: manager,
                                               mode: mode,
                                               onReload: onReload,
                                               onError: onError)
    self.router = router
    super.init()
    router.viewController = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    viewModel.complete()
  }
  
}

// MARK: - Private Methods

private extension AddPaymentMethodViewController {
  
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
      self.openBrowserButton.isLoading = $0
    }.store(in: &subscriptions)
    
    viewModel.error.sink { [weak self] _ in
      self?.router.showToast(title: L.errorAddPaymentMethodTitle,
                             message: L.errorAddPaymentMethodMessage)
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
