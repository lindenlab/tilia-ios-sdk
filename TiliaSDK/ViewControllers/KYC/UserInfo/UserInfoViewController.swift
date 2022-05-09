//
//  UserInfoViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 02.05.2022.
//

import UIKit
import Combine

final class UserInfoViewController: BaseViewController, LoadableProtocol {
  
  var hideableView: UIView { return tableView }
  var spinnerPosition: CGPoint { return view.center }
  
  private let viewModel: UserInfoViewModelProtocol
  private let router: UserInfoRoutingProtocol
  private let builder = UserInfoSectionBuilder()
  private var subscriptions: Set<AnyCancellable> = []
  private var sections: [UserInfoSectionBuilder.Section] = []
  
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
    tableView.register(UserInfoHeaderView.self)
    tableView.register(NonPrimaryButtonWithImageCell.self)
    tableView.register(UserInfoFooterView.self)
    tableView.tableHeaderView = builder.tableHeader()
    tableView.tableFooterView = builder.tableFooter(delegate: self)
    return tableView
  }()
  
  init(manager: NetworkManager) {
    let viewModel = UserInfoViewModel(manager: manager)
    let router = UserInfoRouter()
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
    viewModel.viewDidLoad()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.updateTableHeaderHeight()
    tableView.updateTableFooterHeight()
  }
  
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension UserInfoViewController: UIAdaptivePresentationControllerDelegate {
  
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    // TODO: - Add logic
  }
  
}

// MARK: - UITableViewDataSource

extension UserInfoViewController: UITableViewDataSource {
  
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

extension UserInfoViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return builder.header(for: sections[section],
                          in: tableView,
                          delegate: self)
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return builder.footer(for: sections[section],
                          in: tableView,
                          delegate: self)
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return sections[section].heightForFooter
  }
  
}

// MARK: - NonPrimaryButtonWithImageCellDelegate

extension UserInfoViewController: NonPrimaryButtonWithImageCellDelegate {
  
  func nonPrimaryButtonWithImageCellButtonDidTap(_ cell: NonPrimaryButtonWithImageCell) {
    // TODO: - Add logic
  }
  
}

// MARK: - UserInfoHeaderViewDelegate

extension UserInfoViewController: UserInfoHeaderViewDelegate {
  
  func userInfoHeaderView(_ header: UserInfoHeaderView, willExpand isExpanded: Bool) {
    guard let index = getHeaderIndex(header) else { return }
    viewModel.expandSection(at: index,
                            isExpanded: isExpanded)
  }
  
}

// MARK: - UserInfoFooterViewDelegate

extension UserInfoViewController: UserInfoFooterViewDelegate {
  
  func userInfoFooterViewButtonDidTap(_ footer: UserInfoFooterView) {
    
  }
  
}

// MARK: - ButtonsViewDelegate

extension UserInfoViewController: ButtonsViewDelegate {
  
  func buttonsViewPrimaryButtonDidTap(_ view: ButtonsView) {
    
  }
  
  func buttonsViewPrimaryNonButtonDidTap(_ view: ButtonsView) {
    
  }
  
}

// MARK: - Private Methods

private extension UserInfoViewController {
  
  func setup() {
    view.addSubview(tableView)
    
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
      tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
      tableView.bottomAnchor.constraint(equalTo: divider.topAnchor)
    ])
  }
  
  func bind() {
    viewModel.loading.sink { [weak self] in
      guard let self = self else { return }
      $0 ? self.startLoading() : self.stopLoading()
    }.store(in: &subscriptions)
    
    viewModel.error.sink { [weak self] _ in
      guard let self = self else { return }
      self.router.showToast(title: L.errorPaymentTitle,
                            message: L.errorPaymentMessage)
    }.store(in: &subscriptions)
    
    viewModel.content.sink { [weak self] _ in
      guard let self = self else { return }
      self.sections = self.builder.sections()
      self.tableView.reloadData()
    }.store(in: &subscriptions)
    
    viewModel.section.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateSection(&self.sections[$0.index],
                                 with: $0.model,
                                 isExpanded: $0.isExpanded)
      self.tableView.reloadSections([$0.index], with: .fade)
    }.store(in: &subscriptions)
  }
  
  func getHeaderIndex(_ header: UITableViewHeaderFooterView) -> Int? {
    sections.indices.firstIndex {
      return tableView.headerView(forSection: $0) === header
    }
  }
  
}
