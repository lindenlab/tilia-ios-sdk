//
//  TransactionHistoryViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 15.09.2022.
//

import UIKit
import Combine

final class TransactionHistoryViewController: BaseViewController {
  
  override var hideableView: UIView {
    return contentStackView
  }
  
  private let viewModel: TransactionHistoryViewModelProtocol
  private let router: TransactionHistoryRoutingProtocol
  private var subscriptions: Set<AnyCancellable> = []
  private var viewControllers: [UIViewController] = []
  private var selectedViewController: UIViewController?
  
  private lazy var sectionTypeSegmentedControl: UISegmentedControl = {
    let segmentedControl = UISegmentedControl()
    segmentedControl.addTarget(self, action: #selector(sectionTypeDidChange), for: .valueChanged)
    segmentedControl.selectedSegmentTintColor = .primaryColor
    segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.primaryButtonTextColor], for: .selected)
    segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.primaryTextColor], for: .normal)
    return segmentedControl
  }()
  
  private lazy var sectionTypeStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [sectionTypeSegmentedControl])
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.directionalLayoutMargins = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
    stackView.isHidden = true
    return stackView
  }()
  
  private lazy var closeButtonStackView: UIStackView = {
    let button = NonPrimaryButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(L.close, for: .normal)
    button.addTarget(self, action: #selector(contentCloseButtonDidTap), for: .touchUpInside)
    let stackView = UIStackView(arrangedSubviews: [button])
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.directionalLayoutMargins = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
    stackView.isHidden = true
    return stackView
  }()
  
  private lazy var contentStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [sectionTypeStackView,
                                                   closeButtonStackView])
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
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
    super.init(nibName: nil, bundle: nil)
    TransactionHistorySectionModel.SectionType.allCases.enumerated().forEach { index, item in
      viewControllers.append(TransactionHistoryChildViewController(manager: manager,
                                                                   delegate: viewModel,
                                                                   builder: item.builder))
      sectionTypeSegmentedControl.insertSegment(withTitle: item.description,
                                                at: index,
                                                animated: false)
    }
    sectionTypeSegmentedControl.selectedSegmentIndex = 0
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
  
  override func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    viewModel.complete(isFromCloseAction: false)
  }
  
}

// MARK: - Private Methods

private extension TransactionHistoryViewController {
  
  func setup() {
    view.addSubview(contentStackView)
    
    NSLayoutConstraint.activate([
      contentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      contentStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
      contentStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
      contentStackView.bottomAnchor.constraint(equalTo: divider.topAnchor, constant: -16)
    ])
  }
  
  func setupContent() {
    selectedViewController?.removeAsChildViewController()
    let selectedViewController = viewControllers[sectionTypeSegmentedControl.selectedSegmentIndex]
    self.selectedViewController = selectedViewController
    addChild(selectedViewController)
    contentStackView.insertArrangedSubview(selectedViewController.view, at: 1)
    contentStackView.setCustomSpacing(8, after: selectedViewController.view)
    selectedViewController.didMove(toParent: self)
  }
  
  func bind() {
    viewModel.loading.sink { [weak self] in
      guard let self = self else { return }
      $0 ? self.startLoading() : self.stopLoading()
    }.store(in: &subscriptions)
    
    viewModel.error.sink { [weak self] in
      guard let self = self else { return }
      if $0.value {
        self.showCancelButton()
      }
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
      self.sectionTypeStackView.isHidden = false
      self.closeButtonStackView.isHidden = false
      self.setupContent()
    }.store(in: &subscriptions)
    
    viewModel.selectTransaction.sink { [weak self] in
      self?.router.routeToTransactionDetailsView()
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
  
  @objc func sectionTypeDidChange() {
    setupContent()
  }
  
}
