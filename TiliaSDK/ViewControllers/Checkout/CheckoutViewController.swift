//
//  CheckoutViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import UIKit
import Combine

final class CheckoutViewController: UIViewController, LoadableProtocol {
  
  var hideableView: UIView { return tableView }
  var spinnerPosition: CGPoint { return view.center }
  
  private let viewModel: CheckoutViewModelProtocol
  private let router: CheckoutRoutingProtocol
  private var subscriptions: Set<AnyCancellable> = []
  private var sections: [CheckoutSectionBuilder.Section] = [] {
    didSet {
      tableView.reloadData()
    }
  }
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.showsVerticalScrollIndicator = false
    tableView.backgroundColor = .clear
    tableView.separatorStyle = .none
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(ChekoutTitleHeaderView.self)
    tableView.register(CheckoutPayloadSummaryFooterView.self)
    tableView.register(CheckoutPayloadCell.self)
    tableView.register(CheckoutPaymentFooterView.self)
    tableView.register(CheckoutPaymentMethodCell.self)
    tableView.register(CheckoutSuccessfulPaymentCell.self)
    return tableView
  }()
  
  private let logoImageView: UIImageView = {
    let imageView = UIImageView(image: .logoImage)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private let divider: DividerView = {
    let divider = DividerView()
    divider.translatesAutoresizingMaskIntoConstraints = false
    return divider
  }()
  
  private lazy var closeButton: NonPrimaryButton = {
    let button = NonPrimaryButton()
    button.setTitle(L.close, for: .normal)
    button.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
    viewModel.checkIsTosRequired()
  }
  
  init(invoiceId: String,
       manager: NetworkManager,
       onUpdate: ((TLUpdateCallback) -> Void)?,
       onComplete: ((TLCompleteCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    let viewModel = CheckoutViewModel(invoiceId: invoiceId,
                                      manager: manager,
                                      onUpdate: onUpdate,
                                      onComplete: onComplete,
                                      onError: onError)
    let router = CheckoutRouter(dataStore: viewModel)
    self.viewModel = viewModel
    self.router = router
    super.init(nibName: nil, bundle: nil)
    router.viewController = self
    self.presentationController?.delegate = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - UITableViewDataSource

extension CheckoutViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections[section].numberOfRows
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return sections[indexPath.section].cell(for: tableView, at: indexPath)
  }
  
}

// MARK: - UITableViewDelegate {

extension CheckoutViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return sections[section].header(for: tableView, in: section)
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return sections[section].footer(for: tableView,
                                    in: section,
                                    delegate: self,
                                    textViewDelegate: self)
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return sections[section].heightForHeader
  }
  
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension CheckoutViewController: UIAdaptivePresentationControllerDelegate {
  
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    viewModel.didDismiss(isFromCloseAction: false)
  }
  
}

// MARK: - CheckoutPaymentFooterViewDelegate

extension CheckoutViewController: CheckoutPaymentFooterViewDelegate {
  
  func checkoutPaymentFooterViewPrimaryButtonDidTap(_ footerView: CheckoutPaymentFooterView) {
    viewModel.payInvoice()
  }
  
  func checkoutPaymentFooterViewNonPrimaryButtonDidTap(_ footerView: CheckoutPaymentFooterView) {
    dismiss(isFromCloseAction: false)
  }
  
}

// MARK: - TextViewWithLinkDelegate

extension CheckoutViewController: TextViewWithLinkDelegate {
  
  func textViewWithLink(_ textView: TextViewWithLink, didPressOn link: String) {
    router.showWebView(with: link)
  }
  
}

// MARK: - Private Methods

private extension CheckoutViewController {
  
  func setup() {
    view.backgroundColor = .backgroundColor
    view.addSubview(logoImageView)
    view.addSubview(tableView)
    view.addSubview(divider)
    
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
      tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
      tableView.bottomAnchor.constraint(equalTo: divider.topAnchor),
      divider.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
      divider.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
      divider.bottomAnchor.constraint(equalTo: logoImageView.topAnchor, constant: -16),
      logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      logoImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
    ])
  }
  
  func bind() {
    viewModel.loading.sink { [weak self] in
      guard let self = self else { return }
      $0 ? self.startLoading() : self.stopLoading()
    }.store(in: &subscriptions)
    viewModel.error.sink { [weak self] in
      guard let self = self else { return }
      if $0.needToShowCancelButton {
        self.showCancelButton()
      }
      self.router.showToast(title: L.errorPaymentTitle,
                            message: L.errorPaymentMessage)
    }.store(in: &subscriptions)
    viewModel.needToAcceptTos.sink { [weak self] _ in
      self?.router.routeToTosView()
    }.store(in: &subscriptions)
    viewModel.content.sink { [weak self] in
      guard let content = $0 else { return }
      let builder = CheckoutSectionBuilder()
      self?.sections = [
        builder.summarySection(for: content.invoice),
        builder.paymentSection(for: content.balance)
      ]
    }.store(in: &subscriptions)
    viewModel.successfulPayment.sink { [weak self] in
      guard $0 else { return }
      self?.sections[1] = .successfulPayment
    }.store(in: &subscriptions)
    viewModel.dismiss.sink { [weak self] _ in
      self?.dismiss(isFromCloseAction: false)
    }.store(in: &subscriptions)
  }
  
  func dismiss(isFromCloseAction: Bool) {
    router.dismiss { self.viewModel.didDismiss(isFromCloseAction: isFromCloseAction) }
  }
  
  func showCancelButton() {
    view.addSubview(closeButton)
    NSLayoutConstraint.activate([
      closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      closeButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      closeButton.widthAnchor.constraint(equalToConstant: 100)
    ])
  }
  
  @objc func closeButtonDidTap() {
    dismiss(isFromCloseAction: true)
  }
  
}
