//
//  CheckoutViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import UIKit
import Combine

final class CheckoutViewController: BaseTableViewController {
  
  override var hideableView: UIView {
    return tableView
  }
  
  private let viewModel: CheckoutViewModelProtocol
  private let router: CheckoutRoutingProtocol
  private var subscriptions: Set<AnyCancellable> = []
  private var sections: [CheckoutSectionBuilder.Section] = []
  private let builder = CheckoutSectionBuilder()
  
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
  
  override func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    viewModel.complete(isFromCloseAction: false)
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return builder.numberOfRows(in: sections[section])
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return builder.cell(for: sections[indexPath.section],
                        in: tableView,
                        at: indexPath,
                        delegate: self)
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return builder.header(for: sections[section],
                          in: tableView)
  }

  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return builder.footer(for: sections[section],
                          in: tableView,
                          delegate: self)
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return builder.heightForHeader(in: sections[section])
  }
  
}

// MARK: - CheckoutPaymentFooterViewDelegate

extension CheckoutViewController: CheckoutPaymentFooterViewDelegate {
  
  func checkoutPaymentFooterViewPayButtonDidTap(_ footerView: CheckoutPaymentFooterView) {
    viewModel.payInvoice()
  }
  
  func checkoutPaymentFooterViewAddCreditCardButtonDidTap(_ footerView: CheckoutPaymentFooterView) {
    router.routeToAddCreditCardView()
  }
  
  func checkoutPaymentFooterViewCloseButtonDidTap(_ footerView: CheckoutPaymentFooterView) {
    dismiss(isFromCloseAction: false)
  }
  
}

// MARK: - TextViewWithLinkDelegate

extension CheckoutViewController: TextViewWithLinkDelegate {
  
  func textViewWithLink(_ textView: TextViewWithLink, didPressOn link: String) {
    router.routeToTosContentView()
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
    tableView.register(TitleInfoHeaderFooterView.self)
    tableView.register(CheckoutPayloadSummaryFooterView.self)
    tableView.register(CheckoutPayloadCell.self)
    tableView.register(CheckoutPaymentFooterView.self)
    tableView.register(CheckoutPaymentMethodCell.self)
    tableView.register(ToastViewCell.self)
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
      UIView.performWithoutAnimation {
        self.tableView.reloadSections([1], with: .none)
      }
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
    
    viewModel.updateSummary.sink { [weak self] in
      guard let self = self else { return }
      self.sections[0] = self.builder.updatedSummarySection(for: self.sections[0],
                                                            model: $0)
      UIView.performWithoutAnimation {
        self.tableView.reloadSections([0], with: .none)
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
  
}
