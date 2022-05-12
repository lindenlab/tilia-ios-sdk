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
    tableView.backgroundColor = .backgroundColor
    tableView.separatorStyle = .none
    tableView.delaysContentTouches = false
    tableView.delegate = self
    tableView.dataSource = self
    tableView.addClosingKeyboardOnTap()
    tableView.register(TitleInfoHeaderFooterView.self)
    tableView.register(UserInfoHeaderView.self)
    tableView.register(UserInfoFooterView.self)
    tableView.register(TextFieldCell.self)
    tableView.register(TwoTextFieldsCell.self)
    tableView.register(ThreeTextFieldsCell.self)
    tableView.register(LabelCell.self)
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

// MARK: - TextFieldsCellDelegate

extension UserInfoViewController: TextFieldsCellDelegate {
  
  func textFieldsCell(_ cell: TextFieldsCell, didEndEditingWith text: String?, at index: Int) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    viewModel.setText(text,
                      for: sections[indexPath.section],
                      indexPath: indexPath,
                      fieldIndex: index)
  }
  
}

// MARK: - UserInfoHeaderViewDelegate

extension UserInfoViewController: UserInfoHeaderViewDelegate {
  
  func userInfoHeaderView(_ header: UserInfoHeaderView, willExpand isExpanded: Bool) {
    guard let index = getHeaderIndex(header) else { return }
    viewModel.updateSection(at: index,
                            sectionType: sections[index].type,
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
    router.dismiss()
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
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: UIResponder.keyboardDidShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    viewModel.expandSection.sink { [weak self] item in
      guard let self = self else { return }
      self.builder.updateSection(&self.sections[item.index],
                                 with: item.model,
                                 isExpanded: item.isExpanded,
                                 isFilled: item.isFilled)
      self.tableView.performBatchUpdates {
        self.tableView.reloadSections([item.index], with: .fade)
      } completion: { _ in
        if item.isExpanded {
          self.scrollToSection(at: item.index)
        }
      }
    }.store(in: &subscriptions)
    
    viewModel.setSectionText.sink { [weak self] item in
      guard let self = self else { return }
      self.builder.updateSection(&self.sections[item.indexPath.section],
                                 in: self.tableView,
                                 at: item.indexPath,
                                 text: item.text,
                                 fieldIndex: item.fieldIndex,
                                 isFilled: item.isFilled)
    }.store(in: &subscriptions)
  }
  
  func getHeaderIndex(_ header: UITableViewHeaderFooterView) -> Int? {
    return sections.indices.firstIndex {
      return tableView.headerView(forSection: $0) === header
    }
  }
  
  func scrollToSection(at index: Int) {
    tableView.scrollToRow(at: IndexPath(row: NSNotFound, section: index),
                          at: .top,
                          animated: true)
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
