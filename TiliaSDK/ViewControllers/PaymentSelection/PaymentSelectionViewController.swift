//
//  PaymentSelectionViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.05.2023.
//

import UIKit
import Combine

final class PaymentSelectionViewController: BaseTableViewController {
  
  override var hideableView: UIView {
    return tableView
  }
  
  private let viewModel: PaymentSelectionViewModelProtocol
  private let router: PaymentSelectionRoutingProtocol
  private var subscriptions: Set<AnyCancellable> = []
//  private var sections: [PaymentSelectionSectionBuilder.Section] = []
//  private let builder = PaymentSelectionSectionBuilder()
  
  init(manager: NetworkManager,
       onUpdate: ((TLUpdateCallback) -> Void)?,
       onComplete: ((TLCompleteCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    let viewModel = PaymentSelectionViewModel(manager: manager,
                                              onUpdate: onUpdate,
                                              onComplete: onComplete,
                                              onError: onError)
    let router = PaymentSelectionRouter(dataStore: viewModel)
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
  
//  override func numberOfSections(in tableView: UITableView) -> Int {
//    return sections.count
//  }
//  
//  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return builder.numberOfRows(in: sections[section])
//  }
//  
//  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    return builder.cell(for: sections[indexPath.section],
//                        in: tableView,
//                        at: indexPath,
//                        delegate: self,
//                        isLoading: viewModel.createInvoiceLoading.value)
//  }
//  
//  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//    return builder.header(for: sections[section],
//                          in: tableView)
//  }
//
//  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//    return builder.footer(for: sections[section],
//                          in: tableView,
//                          delegate: self,
//                          isLoading: viewModel.createInvoiceLoading.value)
//  }
  
}

// MARK: - PaymentFooterViewDelegate

extension PaymentSelectionViewController: PaymentFooterViewDelegate {
  
  func paymentFooterViewPayButtonDidTap(_ footerView: PaymentFooterView) {
//    viewModel.payInvoice()
  }
  
  func paymentFooterViewAddCreditCardButtonDidTap(_ footerView: PaymentFooterView) {
    router.routeToAddCreditCardView()
  }
  
  func paymentFooterViewCloseButtonDidTap(_ footerView: PaymentFooterView) {
    dismiss(isFromCloseAction: false)
  }
  
}

// MARK: - TextViewWithLinkDelegate

extension PaymentSelectionViewController: TextViewWithLinkDelegate {
  
  func textViewWithLink(_ textView: TextViewWithLink, didPressOn link: String) {
    router.routeToTosContentView()
  }
  
}

// MARK: - Private Methods

private extension PaymentSelectionViewController {
  
  func setup() {
    tableView.register(TitleInfoHeaderFooterView.self)
    tableView.register(PaymentFooterView.self)
    tableView.register(PaymentMethodRadioCell.self)
    tableView.register(PaymentMethodSwitchCell.self)
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
      self.router.showToast(title: L.errorPaymentSelectionTitle,
                            message: L.errorPaymentSelectionMessage)
    }.store(in: &subscriptions)
    
    viewModel.needToAcceptTos.sink { [weak self] in
      self?.router.routeToTosView()
    }.store(in: &subscriptions)
    
    viewModel.content.sink { [weak self] in
      guard let self = self else { return }
//      self.sections = self.builder.sections(with: $0)
//      self.tableView.reloadData()
    }.store(in: &subscriptions)
    
    viewModel.dismiss.sink { [weak self] in
      self?.dismiss(isFromCloseAction: false)
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
