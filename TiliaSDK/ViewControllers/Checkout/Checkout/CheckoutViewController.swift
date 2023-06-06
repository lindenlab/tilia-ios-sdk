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
  private lazy var limitTextFieldDelegate = LimitTextFieldDelegate(limit: 36)
  
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
                        delegate: self,
                        isLoading: viewModel.createInvoiceLoading.value)
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return builder.header(for: sections[section],
                          in: tableView)
  }

  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return builder.footer(for: sections[section],
                          in: tableView,
                          delegate: self,
                          isLoading: viewModel.createInvoiceLoading.value)
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return builder.heightForHeader(in: sections[section])
  }
  
  override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    return builder.swipeActionsConfiguration(for: sections[indexPath.section],
                                             at: indexPath.row) {
      self.router.routeToDeletePaymentMethodView {
        self.viewModel.removePaymentMethod(at: indexPath.row)
      }
    } andRenameAction: {
      self.viewModel.willRenamePaymentMethod(at: indexPath.row)
    }
  }
  
}

// MARK: - PaymentFooterViewDelegate

extension CheckoutViewController: PaymentFooterViewDelegate {
  
  func paymentFooterViewPayButtonDidTap(_ footerView: PaymentFooterView) {
    viewModel.payInvoice()
  }
  
  func paymentFooterViewAddCreditCardButtonDidTap(_ footerView: PaymentFooterView) {
    router.routeToAddCreditCardView()
  }
  
  func paymentFooterViewCloseButtonDidTap(_ footerView: PaymentFooterView) {
    dismiss(isFromCloseAction: false)
  }
  
}

// MARK: - TextViewWithLinkDelegate

extension CheckoutViewController: TextViewWithLinkDelegate {
  
  func textViewWithLink(_ textView: TextViewWithLink, didPressOn link: String) {
    router.routeToTosContentView()
  }
  
}

// MARK: - PaymentMethodSwitchCellDelegate

extension CheckoutViewController: PaymentMethodSwitchCellDelegate {
  
  func paymentMethodSwitchCell(_ cell: PaymentMethodSwitchCell, didSelect isOn: Bool) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    viewModel.selectPaymentMethod(at: indexPath, isSelected: isOn)
  }
  
}

// MARK: - PaymentMethodRadioCellDelegate

extension CheckoutViewController: PaymentMethodRadioCellDelegate {
  
  func paymentMethodRadioCellDidSelect(_ cell: PaymentMethodRadioCell) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    viewModel.selectPaymentMethod(at: indexPath)
  }
  
}

// MARK: - Private Methods

private extension CheckoutViewController {
  
  func setup() {
    tableView.register(TitleInfoHeaderFooterView.self)
    tableView.register(CheckoutPayloadSummaryFooterView.self)
    tableView.register(CheckoutPayloadCell.self)
    tableView.register(PaymentFooterView.self)
    tableView.register(PaymentMethodRadioCell.self)
    tableView.register(PaymentMethodSwitchCell.self)
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
    
    viewModel.needToAcceptTos.sink { [weak self] in
      self?.router.routeToTosView()
    }.store(in: &subscriptions)
    
    viewModel.content.sink { [weak self] in
      guard let self = self else { return }
      self.sections = self.builder.sections(with: $0)
      self.tableView.reloadData()
    }.store(in: &subscriptions)
    
    viewModel.successfulPayment.sink { [weak self] in
      guard let self = self, $0 else { return }
      let reloadSections = self.builder.updateSectionsWithSuccessfulPayment(&self.sections)
      UIView.performWithoutAnimation {
        self.tableView.reloadSections(reloadSections, with: .none)
      }
    }.store(in: &subscriptions)
    
    viewModel.dismiss.sink { [weak self] in
      self?.dismiss(isFromCloseAction: false)
    }.store(in: &subscriptions)
    
    viewModel.createInvoiceLoading.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateSections(self.sections,
                                  in: self.tableView,
                                  isLoading: $0)
    }.store(in: &subscriptions)
    
    viewModel.payButtonIsEnabled.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateSection(&self.sections[$0.sectionIndex],
                                 in: self.tableView,
                                 at: $0.sectionIndex,
                                 isPayButtonEnabled: $0.isEnabled)
    }.store(in: &subscriptions)
    
    viewModel.deselectIndex.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateSection(&self.sections[$0.section],
                                 in: self.tableView,
                                 at: $0,
                                 isSelected: false)
    }.store(in: &subscriptions)
    
    viewModel.selectIndex.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateSection(&self.sections[$0.section],
                                 in: self.tableView,
                                 at: $0,
                                 isSelected: true)
    }.store(in: &subscriptions)
    
    viewModel.updateSummary.sink { [weak self] in
      guard let self = self else { return }
      let reloadSections = self.builder.updateSummarySection(for: &self.sections,
                                                             model: $0)
      UIView.performWithoutAnimation {
        self.tableView.reloadSections(reloadSections, with: .none)
      }
    }.store(in: &subscriptions)
    
    viewModel.updatePayment.sink { [weak self] in
      guard let self = self else { return }
      let reloadSections = self.builder.updatePaymentSection(for: &self.sections,
                                                             model: $0)
      UIView.performWithoutAnimation {
        self.tableView.reloadSections(reloadSections, with: .none)
      }
    }.store(in: &subscriptions)
    
    viewModel.paymentMethodsAreEnabled.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateSection(&self.sections[$0.sectionIndex],
                                 in: self.tableView,
                                 at: $0.sectionIndex,
                                 isEnabled: $0.isEnabled)
    }.store(in: &subscriptions)
    
    viewModel.renamePaymentMethod.sink { [weak self] model in
      guard let self = self else { return }
      self.router.routeToRenamePaymentMethodView(with: model.name, textFieldDelegate: self.limitTextFieldDelegate) {
        self.viewModel.didRenamePaymentMethod(at: model.index, with: $0)
      }
    }.store(in: &subscriptions)
  }
  
  func dismiss(isFromCloseAction: Bool) {
    router.dismiss { self.viewModel.complete(isFromCloseAction: isFromCloseAction) }
  }
  
  func showCancelButton() {
    showCloseButton(target: self, action: #selector(closeButtonDidTap))
  }
  
  @objc func closeButtonDidTap() {
    dismiss(isFromCloseAction: true)
  }
  
}
