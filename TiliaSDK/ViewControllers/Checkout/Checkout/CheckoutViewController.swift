//
//  CheckoutViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import UIKit
import Combine

final class CheckoutViewController: BaseViewController, LoadableProtocol {
  
  var hideableView: UIView { return tableView }
  var spinnerPosition: CGPoint { return view.center }
  
  private let viewModel: CheckoutViewModelProtocol
  private let router: CheckoutRoutingProtocol
  private var subscriptions: Set<AnyCancellable> = []
  private var sections: [CheckoutSectionBuilder.Section] = []
  private let builder = CheckoutSectionBuilder()
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.showsVerticalScrollIndicator = false
    tableView.backgroundColor = .clear
    tableView.separatorStyle = .none
    tableView.delaysContentTouches = false
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(TitleInfoHeaderFooterView.self)
    tableView.register(CheckoutPayloadSummaryFooterView.self)
    tableView.register(CheckoutPayloadCell.self)
    tableView.register(CheckoutPaymentFooterView.self)
    tableView.register(CheckoutPaymentMethodCell.self)
    tableView.register(CheckoutSuccessfulPaymentCell.self)
    return tableView
  }()
  
  private lazy var closeButton: NonPrimaryButton = {
    let button = NonPrimaryButton()
    button.setTitle(L.close, for: .normal)
    button.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.accessibilityIdentifier = "closeButton"
    return button
  }()
  
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
    viewModel.checkIsTosRequired()
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
    return builder.cell(for: sections[indexPath.section],
                        in: tableView,
                        at: indexPath,
                        delegate: self)
  }
  
}

// MARK: - UITableViewDelegate {

extension CheckoutViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return builder.header(for: sections[section],
                          in: tableView)
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return builder.footer(for: sections[section],
                          in: tableView,
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
    viewModel.complete(isFromCloseAction: false)
  }
  
}

// MARK: - CheckoutPaymentFooterViewDelegate

extension CheckoutViewController: CheckoutPaymentFooterViewDelegate {
  
  func checkoutPaymentFooterViewPayButtonDidTap(_ footerView: CheckoutPaymentFooterView) {
    viewModel.payInvoice()
  }
  
  func checkoutPaymentFooterViewAddCreditCardButtonDidTap(_ footerView: CheckoutPaymentFooterView) {
    router.routeToAddCreditCard()
  }
  
  func checkoutPaymentFooterViewCloseButtonDidTap(_ footerView: CheckoutPaymentFooterView) {
    dismiss(isFromCloseAction: false)
  }
  
}

// MARK: - TextViewWithLinkDelegate

extension CheckoutViewController: TextViewWithLinkDelegate {
  
  func textViewWithLink(_ textView: TextViewWithLink, didPressOn link: String) {
    router.showWebView(with: link)
  }
  
}

// MARK: - CheckoutPaymentMethodCellDelegate

extension CheckoutViewController: CheckoutPaymentMethodCellDelegate {
  
  func checkoutPaymentMethodCellRadioButtonDidTap(_ cell: CheckoutPaymentMethodCell) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    viewModel.selectPaymentMethod(at: indexPath.row)
  }
  
}

// MARK: - Private Methods

private extension CheckoutViewController {
  
  func setup() {
    view.addSubview(tableView)
    
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
      tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
      tableView.bottomAnchor.constraint(equalTo: divider.topAnchor),
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
      guard let self = self else { return }
      self.sections = self.builder.sections(with: $0)
      self.tableView.reloadData()
    }.store(in: &subscriptions)
    
    viewModel.successfulPayment.sink { [weak self] in
      guard let self = self, $0 else { return }
      self.sections[1] = self.builder.successfulPaymentSection()
      self.tableView.reloadData()
    }.store(in: &subscriptions)
    
    viewModel.dismiss.sink { [weak self] _ in
      self?.dismiss(isFromCloseAction: false)
    }.store(in: &subscriptions)
    
    viewModel.createInvoiceLoading.sink { [weak self] in
      guard let self = self else { return }
      self.sections[0] = self.builder.updatedSummarySection(for: self.sections[0],
                                                            in: self.tableView,
                                                            at: 0,
                                                            isLoading: $0)
    }.store(in: &subscriptions)
    
    viewModel.payButtonIsEnabled.sink { [weak self] in
      guard let self = self else { return }
      self.sections[1] = self.builder.updatedPaymentSection(for: self.sections[1],
                                                            in: self.tableView,
                                                            at: 1,
                                                            isPayButtonEnabled: $0)
    }.store(in: &subscriptions)
    
    viewModel.deselectIndex.sink { [weak self] in
      guard let self = self else { return }
      let indexPath = IndexPath(row: $0, section: 1)
      self.sections[1] = self.builder.updatedPaymentSection(for: self.sections[1],
                                                            in: self.tableView,
                                                            at: indexPath,
                                                            isSelected: false)
    }.store(in: &subscriptions)
    
    viewModel.selectIndex.sink { [weak self] in
      guard let self = self else { return }
      let indexPath = IndexPath(row: $0, section: 1)
      self.sections[1] = self.builder.updatedPaymentSection(for: self.sections[1],
                                                            in: self.tableView,
                                                            at: indexPath,
                                                            isSelected: true)
    }.store(in: &subscriptions)
  }
  
  func dismiss(isFromCloseAction: Bool) {
    router.dismiss { self.viewModel.complete(isFromCloseAction: isFromCloseAction) }
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
