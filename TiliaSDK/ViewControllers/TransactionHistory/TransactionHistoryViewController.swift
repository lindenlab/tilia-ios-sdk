//
//  TransactionHistoryViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 15.09.2022.
//

import UIKit
import Combine

final class TransactionHistoryViewController: BaseTableViewController {
  
  override var hideableView: UIView {
    return tableView
  }
  
  private let viewModel: TransactionHistoryViewModelProtocol
  private let router: TransactionHistoryRoutingProtocol
  private var subscriptions: Set<AnyCancellable> = []
  
  private lazy var contentCloseButton: NonPrimaryButton = {
    let button = NonPrimaryButton()
    button.isHidden = true
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(L.close, for: .normal)
    button.addTarget(self, action: #selector(contentCloseButtonDidTap), for: .touchUpInside)
    return button
  }()
  
  init(manager: NetworkManager,
       onUpdate: ((TLUpdateCallback) -> Void)?,
       onComplete: ((TLCompleteCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    let viewModel = TransactionHistoryViewModel(manager: manager,
                                                onUpdate: onUpdate,
                                                onComplete: onComplete,
                                                onError: onError)
    let router = TransactionHistoryRouter(dataStore: viewModel)
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
    viewModel.checkIsTosRequired()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.contentInset.bottom = contentCloseButton.frame.height + 32
  }
  
  override func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    viewModel.complete(isFromCloseAction: false)
  }
  
}

// MARK: - Private Methods

private extension TransactionHistoryViewController {
  
  func setup() {
    view.addSubview(contentCloseButton)
    NSLayoutConstraint.activate([
      contentCloseButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
      contentCloseButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
      contentCloseButton.bottomAnchor.constraint(equalTo: divider.topAnchor, constant: -16),
    ])
  }
  
  func bind() {
    viewModel.loading.sink { [weak self] in
      guard let self = self else { return }
      $0 ? self.startLoading() : self.stopLoading()
    }.store(in: &subscriptions)
    
    viewModel.error.sink { [weak self] _ in
      guard let self = self else { return }
      self.showCancelButton() // TODO: - Add here showing button only on first error - when content is failed fully
      self.router.showToast(title: L.errorTransactionHistoryTitle,
                            message: L.errorTransactionHistoryMessage)
    }.store(in: &subscriptions)
    
    viewModel.needToAcceptTos.sink { [weak self] in
      self?.router.routeToTosView()
    }.store(in: &subscriptions)
    
    viewModel.dismiss.sink { [weak self] in
      self?.dismiss(isFromCloseAction: false)
    }.store(in: &subscriptions)
    
    viewModel.content.sink { [weak self] in
      guard let self = self else { return }
      if self.contentCloseButton.isHidden {
        self.contentCloseButton.isHidden = false
      }
    }.store(in: &subscriptions)
  }
  
  func dismiss(isFromCloseAction: Bool) {
    router.dismiss { self.viewModel.complete(isFromCloseAction: isFromCloseAction) }
  }
  
  func showCancelButton() {
    closeButton.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
  }
  
  @objc func closeButtonDidTap() {
    dismiss(isFromCloseAction: true)
  }
  
  @objc func contentCloseButtonDidTap() {
    dismiss(isFromCloseAction: false)
  }
  
}
