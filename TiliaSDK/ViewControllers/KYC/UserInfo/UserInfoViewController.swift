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
    tableView.register(UserInfoHeaderView.self)
    tableView.register(UserInfoFooterView.self)
    tableView.register(UserInfoNextButtonCell.self)
    tableView.register(TextFieldCell.self)
    tableView.register(TwoTextFieldsCell.self)
    tableView.register(ThreeTextFieldsCell.self)
    tableView.register(LabelCell.self)
    tableView.tableHeaderView = builder.tableHeader()
    tableView.estimatedRowHeight = 150
    tableView.estimatedSectionHeaderHeight = 50
    tableView.estimatedSectionFooterHeight = 140
    return tableView
  }()
  
  init(manager: NetworkManager) {
    let viewModel = UserInfoViewModel(manager: manager)
    let router = UserInfoRouter(dataStore: viewModel)
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
    tableView.updateTableHeaderHeightIfNeeded()
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

extension UserInfoViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return builder.header(for: sections[section],
                          in: tableView,
                          delegate: self)
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return builder.footer(for: sections,
                          in: tableView,
                          at: section,
                          delegate: self)
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return builder.heightForFooter(in: sections[section])
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

// MARK: - UserInfoNextButtonCellDelegate

extension UserInfoViewController: UserInfoNextButtonCellDelegate {
  
  func userInfoNextButtonCellButtonDidTap(_ cell: UserInfoNextButtonCell) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    let section = indexPath.section
    viewModel.updateSection(at: section,
                            sectionType: sections[section].type,
                            isExpanded: false)
  }
  
}

// MARK: - UserInfoHeaderViewDelegate

extension UserInfoViewController: UserInfoHeaderViewDelegate {
  
  func userInfoHeaderView(_ header: UserInfoHeaderView, willExpand isExpanded: Bool) {
    tableView.endEditing(true)
    guard let index = getHeaderIndex(header) else { return }
    viewModel.updateSection(at: index,
                            sectionType: sections[index].type,
                            isExpanded: isExpanded)
  }
  
}

// MARK: - ButtonsViewDelegate

extension UserInfoViewController: ButtonsViewDelegate {
  
  func buttonsViewPrimaryButtonDidTap() {
    for (index, section) in sections.enumerated() where section.mode == .expanded {
      viewModel.updateSection(at: index,
                              sectionType: section.type,
                              isExpanded: false)
    }
    router.routeToUserDocumentsView()
  }
  
  func buttonsViewPrimaryNonButtonDidTap() {
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
      let indexPaths = self.builder.updateSection(&self.sections[item.index],
                                                  with: item.model,
                                                  in: self.tableView,
                                                  at: item.index,
                                                  isExpanded: item.isExpanded,
                                                  isFilled: item.isFilled)
      self.tableView.performBatchUpdates {
        if item.isExpanded {
          self.tableView.insertRows(at: indexPaths, with: .fade)
        } else {
          self.tableView.deleteRows(at: indexPaths, with: .fade)
        }
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
      self.builder.updateTableFooter(for: self.sections,
                                     in: self.tableView)
    }.store(in: &subscriptions)
    
    viewModel.coutryOfResidenceDidChange.sink { [weak self] text in
      guard
        let self = self,
        let sectionIndex = self.sections.firstIndex(where: { $0.type == .contact }),
        let itemIndex = self.sections[sectionIndex].items.firstIndex(where: { $0.type == .countryOfResidance }) else { return }
      self.builder.updateSection(&self.sections[sectionIndex],
                                 in: self.tableView,
                                 at: IndexPath(row: itemIndex, section: sectionIndex),
                                 countryOfResidenceDidChangeWith: text)
    }.store(in: &subscriptions)
    
    viewModel.coutryOfResidenceDidSelect.sink { [weak self] _ in
      guard let self = self else { return }
      let indices = self.sections.enumerated().filter { $1.mode == .disabled }
      indices.forEach { index, _ in
        self.builder.updateSection(&self.sections[index],
                                   in: self.tableView,
                                   at: index,
                                   mode: .normal)
      }
    }.store(in: &subscriptions)
  }
  
  func getHeaderIndex(_ header: UITableViewHeaderFooterView) -> Int? {
    return sections.indices.firstIndex {
      return tableView.headerView(forSection: $0) === header
    }
  }
  
  func scrollToSection(at index: Int) {
    tableView.scrollToRow(at: IndexPath(row: 0, section: index),
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
