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
  private var section: UserDocumentsSectionBuilder.Section!
  
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
    tableView.register(TextFieldCell.self)
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
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return builder.numberOfRows(in: self.section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return builder.cell(for: section,
                        in: tableView,
                        at: indexPath,
                        delegate: self)
  }
  
}

// MARK: - UITableViewDelegate {

extension UserDocumentsViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return builder.header(for: self.section,
                          in: tableView)
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return builder.footer(for: self.section,
                          in: tableView,
                          delegate: self)
  }
  
}

// MARK: - TextFieldsCellDelegate

extension UserDocumentsViewController: TextFieldsCellDelegate {
  
  func textFieldsCell(_ cell: TextFieldsCell, didEndEditingWith text: String?, at index: Int) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    viewModel.setText(text,
                      for: section.items[indexPath.row],
                      at: indexPath.row)
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
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: UIResponder.keyboardDidShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  func bind() {
    viewModel.error.sink { [weak self] _ in
      guard let self = self else { return }
      // TODO: - Fix me
//      self.router.showToast(title: L.errorPaymentTitle,
//                            message: L.errorPaymentMessage)
    }.store(in: &subscriptions)
    
    viewModel.content.sink { [weak self] in
      guard let self = self else { return }
      self.section = self.builder.documetsSection(with: $0)
      self.tableView.reloadData()
    }.store(in: &subscriptions)
    
    viewModel.setText.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateSection(&self.section,
                                 at: $0.index,
                                 text: $0.text)
    }.store(in: &subscriptions)
    
    viewModel.documentDidSelect.sink { [weak self] in
      guard let self = self else { return }
      let indexPaths = self.builder.updateSection(&self.section,
                                                  didSelectDocumentWith: $0)
      self.tableView.insertRows(at: indexPaths, with: .fade)
    }.store(in: &subscriptions)
    
    viewModel.documentDidChange.sink { [weak self] in
      guard let self = self else { return }
      let tableUpdate = self.builder.updateSection(&self.section,
                                                   didChangeDocument: $0)
      self.tableView.performBatchUpdates {
        self.tableView.reloadRows(at: tableUpdate.reload, with: .fade)
        tableUpdate.insert.map { self.tableView.insertRows(at: $0, with: .fade) }
        tableUpdate.delete.map { self.tableView.deleteRows(at: $0, with: .fade) }
      }
    }.store(in: &subscriptions)
  }
  
  @objc func keyboardWasShown(_ notificiation: NSNotification) {
    guard
      let value = notificiation.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
      let firstResponder = self.view.firstResponder else { return }
    let bottomInset = self.view.frame.height - divider.frame.midY
    tableView.contentInset.bottom = value.cgRectValue.height - bottomInset
    let rect = firstResponder.convert(firstResponder.frame, to: self.tableView)
    tableView.scrollRectToVisible(rect, animated: true)
  }
  
  @objc func keyboardWillBeHidden() {
    tableView.contentInset.bottom = 0
  }
  
}
