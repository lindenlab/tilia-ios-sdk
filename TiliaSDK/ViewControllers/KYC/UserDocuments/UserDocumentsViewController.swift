//
//  UserDocumentsViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 17.05.2022.
//

import UIKit
import Combine

final class UserDocumentsViewController: BaseViewController {
  
  private let viewModel: UserDocumentsViewModelProtocol
  private let router: UserDocumentsRoutingProtocol
  private let builder = UserDocumentsSectionBuilder()
  private var subscriptions: Set<AnyCancellable> = []
  private var sections: [Any] = []
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.showsVerticalScrollIndicator = false
    tableView.backgroundColor = .backgroundColor
    tableView.separatorStyle = .none
    tableView.delaysContentTouches = false
    tableView.delegate = self
    tableView.dataSource = self
    tableView.addClosingKeyboardOnTap()
    tableView.register(UserDocumentPhotoCell.self)
    tableView.tableHeaderView = builder.tableHeader()
    tableView.tableFooterView = builder.tableFooter(delegate: self)
    tableView.estimatedRowHeight = 44
    return tableView
  }()
  
  init(manager: NetworkManager) {
    let viewModel = UserDocumentsViewModel(manager: manager)
    let router = UserDocumentsRouter()
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
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.updateTableHeaderHeight()
    tableView.updateTableFooterHeight()
    tableView.performBatchUpdates(nil, completion: nil)
  }
  
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension UserDocumentsViewController: UIAdaptivePresentationControllerDelegate {
  
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    // TODO: - Add logic
  }
  
}

// MARK: - UITableViewDataSource

extension UserDocumentsViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeue(UserDocumentPhotoCell.self, for: indexPath)
    cell.configure(title: "Back side", image: .passportIcon, primaryButtonTitle: indexPath.row == 0 ? L.captureOnCamera : nil, nonPrimaryButtonTitle: L.pickFile)
    return cell
  }
  
}

// MARK: - UITableViewDelegate {

extension UserDocumentsViewController: UITableViewDelegate {
  
}

// MARK: - ButtonsViewDelegate

extension UserDocumentsViewController: ButtonsViewDelegate {
  
  func buttonsViewPrimaryButtonDidTap() {
    
  }
  
  func buttonsViewPrimaryNonButtonDidTap() {
    router.dismiss()
  }
  
}

// MARK: - Private Methods

private extension UserDocumentsViewController {
  
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
    
  }
  
}
