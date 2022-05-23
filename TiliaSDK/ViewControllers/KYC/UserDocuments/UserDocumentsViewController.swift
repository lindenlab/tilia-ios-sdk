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
  private var sections: [UserDocumentsSectionBuilder.Section] = []
  
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
    tableView.register(UserDocumentsPhotoCell.self)
    tableView.register(TitleInfoHeaderFooterView.self)
    tableView.register(UserDocumentsFooterView.self)
    tableView.estimatedRowHeight = 100
    tableView.estimatedSectionHeaderHeight = 100
    tableView.estimatedSectionFooterHeight = 140
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
    viewModel.viewDidLoad()
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
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return builder.numberOfRows(in: sections[section])
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return builder.cell(for: sections[indexPath.section],
                        in: tableView,
                        at: indexPath,
                        delegate: self)
  }
  
}

// MARK: - UITableViewDelegate {

extension UserDocumentsViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return builder.header(for: sections[section],
                          in: tableView)
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return builder.footer(for: sections[section],
                          in: tableView,
                          delegate: self)
  }
  
}

// MARK: - TextFieldsCellDelegate

extension UserDocumentsViewController: TextFieldsCellDelegate {
  
  func textFieldsCell(_ cell: TextFieldsCell, didEndEditingWith text: String?, at index: Int) {
    
  }
  
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
    viewModel.error.sink { [weak self] _ in
      guard let self = self else { return }
      // TODO: - Fix me
//      self.router.showToast(title: L.errorPaymentTitle,
//                            message: L.errorPaymentMessage)
    }.store(in: &subscriptions)
    
    viewModel.content.sink { [weak self] _ in
      guard let self = self else { return }
      self.sections = [self.builder.documetsSection()]
      self.tableView.reloadData()
    }.store(in: &subscriptions)
  }
  
}
