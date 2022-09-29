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
  
  private lazy var contentStackView: UIStackView = {
    tableView.removeFromSuperview()
    let stackView = UIStackView(arrangedSubviews: [tableView, closeButtonStackView])
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.translatesAutoresizingMaskIntoConstraints = false
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
  
  override func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    viewModel.complete(isFromCloseAction: false)
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 5
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeue(TransactionHistoryCell.self, for: indexPath)
    let value = NSMutableAttributedString(string: "String", attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: UIColor.red])
    let isDividerHidden = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
    cell.configure(title: "Tile", subTitle: "SubTitle", value: value, subValueImage: .failureIcon?.withRenderingMode(.alwaysTemplate), subValueTitle: "Failed", isDividerHidden: isDividerHidden)
    return cell
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = tableView.dequeue(TransactionHistoryHeaderView.self)
    let value = "3 total".attributedString(font: .boldSystemFont(ofSize: 12), color: .tertiaryTextColor, subStrings: ("total", UIFont.systemFont(ofSize: 12), UIColor.tertiaryTextColor))
    view.configure(title: "String", value: value)
    return view
  }
  
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let view = tableView.dequeue(DividerHeaderFooterView.self)
    view.configure(insets: .init(top: 8, left: 0, bottom: 0, right: 0))
    return view
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
}

// MARK: - Private Methods

private extension TransactionHistoryViewController {
  
  func setup() {
    tableView.register(TransactionHistoryHeaderView.self)
    tableView.register(TransactionHistoryCell.self)
    tableView.register(DividerHeaderFooterView.self)
    view.addSubview(contentStackView)
    
    NSLayoutConstraint.activate([
      contentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
