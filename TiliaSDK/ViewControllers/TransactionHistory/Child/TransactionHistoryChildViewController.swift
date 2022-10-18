//
//  TransactionHistoryChildViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 04.10.2022.
//

import UIKit
import Combine

final class TransactionHistoryChildViewController: UITableViewController {
  
  private let viewModel: TransactionHistoryChildViewModelProtocol
  private let builder: TransactionHistorySectionBuilder
  private var subscriptions: Set<AnyCancellable> = []
  private var sections: [TransactionHistorySectionModel] = []
  
  init(manager: NetworkManager,
       sectionType: TransactionHistorySectionTypeModel,
       delegate: TransactionHistoryChildViewModelDelegate?) {
    self.viewModel = TransactionHistoryChildViewModel(manager: manager,
                                                      sectionType: sectionType,
                                                      delegate: delegate)
    self.builder = sectionType.builder
    super.init(style: .plain)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
    viewModel.loadTransactions()
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
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return builder.heightForHeader(in: sections[section])
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return .leastNormalMagnitude
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    viewModel.selectTransaction(at: index(for: indexPath))
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard tableView.tableFooterView != nil,
          indexPath == tableView.indexPathOfLastRow else { return }
    viewModel.loadMoreTransactions()
  }
  
}

// MARK: - Private Methods

private extension TransactionHistoryChildViewController {
  
  func setup() {
    if #available(iOS 15.0, *) {
      tableView.sectionHeaderTopPadding = 0
    }
    tableView.showsVerticalScrollIndicator = false
    tableView.backgroundColor = .backgroundColor
    tableView.separatorStyle = .none
    tableView.delaysContentTouches = false
    tableView.register(TransactionHistoryHeaderView.self)
    tableView.register(TransactionHistoryCell.self)
    
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(contentDidRefresh), for: .valueChanged)
    self.refreshControl = refreshControl
  }
  
  func bind() {
    viewModel.loading.sink { [weak self] in
      guard let self = self else { return }
      if $0 {
        self.tableView.refreshControl?.beginRefreshing()
      } else {
        self.tableView.refreshControl?.endRefreshing()
      }
    }.store(in: &subscriptions)

    viewModel.content.sink { [weak self] in
      guard let self = self else { return }
      if $0.needReload {
        self.sections.removeAll()
        self.builder.updateTable(self.tableView, isEmpty: $0.models.isEmpty)
      }
      self.builder.updateTable(self.tableView, hasMore: $0.hasMore)
      let tableUpdate = self.builder.updateSections(&self.sections,
                                                    in: self.tableView,
                                                    with: $0.models,
                                                    oldLastItem: $0.lastItem)
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
  
  @objc func contentDidRefresh() {
    viewModel.loadTransactions()
  }
  
  func index(for indexPath: IndexPath) -> Int {
    var index = 0
    for section in 0..<tableView.numberOfSections {
      if section == indexPath.section {
        index += indexPath.row
        break
      } else {
        index += tableView.numberOfRows(inSection: section)
      }
    }
    return index
  }
  
}
