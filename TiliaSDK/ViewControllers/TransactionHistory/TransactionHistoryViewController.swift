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
    return contentStackView
  }
  
  private let viewModel: TransactionHistoryViewModelProtocol
  private let router: TransactionHistoryRoutingProtocol
  private var subscriptions: Set<AnyCancellable> = []
  private var sections: [TransactionHistorySectionBuilder.Section] = []
  private let builder = TransactionHistorySectionBuilder()
  
  private lazy var sectionTypeSegmentedControl: UISegmentedControl = {
    let titles = TransactionHistorySectionBuilder.SectionType.allCases.map { $0.description }
    let segmentedControl = UISegmentedControl(items: titles)
    segmentedControl.addTarget(self, action: #selector(sectionTypeDidChange), for: .valueChanged)
    segmentedControl.selectedSegmentTintColor = .primaryColor
    segmentedControl.selectedSegmentIndex = viewModel.selectedSegmentIndex
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
    tableView.removeFromSuperview()
    let stackView = UIStackView(arrangedSubviews: [sectionTypeStackView,
                                                   tableView,
                                                   closeButtonStackView])
    stackView.axis = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.setCustomSpacing(8, after: tableView)
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
    super.init(style: .plain)
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
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return .leastNormalMagnitude
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    router.routeToTransactionDetailsView()
  }
  
}

// MARK: - Private Methods

private extension TransactionHistoryViewController {
  
  func setup() {
    if #available(iOS 15.0, *) {
      tableView.sectionHeaderTopPadding = 0
    }
    tableView.register(TransactionHistoryHeaderView.self)
    tableView.register(TransactionHistoryCell.self)
    view.addSubview(contentStackView)
    
    NSLayoutConstraint.activate([
      contentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      contentStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
      contentStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
      contentStackView.bottomAnchor.constraint(equalTo: divider.topAnchor, constant: -16)
    ])
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
      if self.closeButtonStackView.isHidden {
        self.closeButtonStackView.isHidden = false
      }
      if self.sectionTypeStackView.isHidden {
        self.sectionTypeStackView.isHidden = false
      }
      if $0.needReload {
        self.sections.removeAll()
      }
      if $0.hasMore {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()
        self.tableView.tableFooterView = spinner
      } else {
        self.tableView.tableFooterView = nil
      }
      
      let tableUpdate = self.builder.updateSections(with: $0.models,
                                                    for: $0.sectionType,
                                                    oldLastItem: $0.lastItem,
                                                    sections: &self.sections)
      if $0.needReload {
        self.tableView.reloadData()
      } else {
        UIView.performWithoutAnimation {
          self.tableView.performBatchUpdates {
            tableUpdate.insertRows.map { self.tableView.insertRows(at: $0, with: .fade) }
            tableUpdate.insertSections.map { self.tableView.insertSections($0, with: .fade) }
          }
        }
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
  
  @objc func sectionTypeDidChange() {
    viewModel.setSelectedSegmentIndex(sectionTypeSegmentedControl.selectedSegmentIndex)
  }
  
}
