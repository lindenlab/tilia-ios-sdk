//
//  TransactionDetailsViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 19.08.2022.
//

import UIKit
import Combine

final class TransactionDetailsViewController: BaseTableViewController {
  
  override var hideableView: UIView {
    return tableView
  }
  
  private let viewModel: TransactionDetailsViewModelProtocol
  private let router: TransactionDetailsRoutingProtocol
  private var subscriptions: Set<AnyCancellable> = []
  private var sections: [TransactionDetailsSectionBuilder.Section] = []
  private let builder = TransactionDetailsSectionBuilder()
  
  init(invoiceId: String,
       manager: NetworkManager,
       onUpdate: ((TLUpdateCallback) -> Void)?,
       onComplete: ((TLCompleteCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    let viewModel = TransactionDetailsViewModel(invoiceId: invoiceId,
                                                manager: manager,
                                                onUpdate: onUpdate,
                                                onComplete: onComplete,
                                                onError: onError)
    let router = TransactionDetailsRouter(dataStore: viewModel)
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
                        at: indexPath)
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return builder.header(for: sections[section],
                          in: tableView)
  }

  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return builder.footer(for: sections[section],
                          in: tableView,
                          at: section,
                          delegate: self)
  }
  
}

// MARK: - ButtonsViewDelegate

extension TransactionDetailsViewController: ButtonsViewDelegate {
  
  func buttonsViewPrimaryButtonDidTap() {
  }
  
  func buttonsViewPrimaryNonButtonDidTap() {
    dismiss(isFromCloseAction: false)
  }
  
}

// MARK: - Private Methods

private extension TransactionDetailsViewController {
  
  func setup() {
    tableView.register(TransactionDetailsHeaderView.self)
    tableView.register(TransactionDetailsTitleHeaderView.self)
    tableView.register(TransactionDetailsTitleFooterView.self)
    tableView.register(TransactionDetailsCell.self)
    tableView.register(TransactionDetailsFooterView.self)
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
      self.router.showToast(title: L.errorTransactionDetailsTitle,
                            message: L.errorTransactionDetailsMessage)
    }.store(in: &subscriptions)
    
    viewModel.needToAcceptTos.sink { [weak self] _ in
      self?.router.routeToTosView()
    }.store(in: &subscriptions)
    
    viewModel.content.sink { [weak self] in
      guard let self = self else { return }
      self.sections = self.builder.sections()
      self.tableView.reloadData()
    }.store(in: &subscriptions)
    
    viewModel.dismiss.sink { [weak self] _ in
      self?.dismiss(isFromCloseAction: false)
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
