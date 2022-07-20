//
//  UserInfoViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 02.05.2022.
//

import UIKit
import Combine

final class UserInfoViewController: BaseViewController {
  
  override var hideableView: UIView {
    return tableView
  }
  
  private let viewModel: UserInfoViewModelProtocol
  private let router: UserInfoRoutingProtocol
  private let builder = UserInfoSectionBuilder()
  private var subscriptions: Set<AnyCancellable> = []
  private lazy var sections: [UserInfoSectionBuilder.Section] = builder.sections()
  
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
    return tableView
  }()
  
  init(manager: NetworkManager,
       onComplete: ((Bool) -> Void)?,
       onError: ((Error) -> Void)?) {
    let viewModel = UserInfoViewModel(manager: manager,
                                      onComplete: onComplete,
                                      onError: onError)
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
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.updateTableHeaderHeightIfNeeded()
  }
  
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension UserInfoViewController: UIAdaptivePresentationControllerDelegate {
  
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    viewModel.complete()
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
    let index = indexPath.section
    var nextSectionIndex: Int?
    for i in index + 1..<sections.count {
      if sections[i].mode == .expanded {
        break
      } else if sections[i].mode == .normal {
        nextSectionIndex = i
        break
      }
    }
    viewModel.updateSection(sections[index],
                            at: index,
                            isExpanded: false,
                            nextSectionIndex: nextSectionIndex)
  }
  
}

// MARK: - UserInfoHeaderViewDelegate

extension UserInfoViewController: UserInfoHeaderViewDelegate {
  
  func userInfoHeaderView(_ header: UserInfoHeaderView, willExpand isExpanded: Bool) {
    tableView.endEditing(true)
    guard let index = getHeaderIndex(header) else { return }
    viewModel.updateSection(sections[index],
                            at: index,
                            isExpanded: isExpanded,
                            nextSectionIndex: nil)
  }
  
}

// MARK: - ButtonsViewDelegate

extension UserInfoViewController: ButtonsViewDelegate {
  
  func buttonsViewPrimaryButtonDidTap() {
    for (index, section) in sections.enumerated() where section.mode == .expanded {
      viewModel.updateSection(section,
                              at: index,
                              isExpanded: false,
                              nextSectionIndex: nil)
    }
    router.routeToUserDocumentsView()
  }
  
  func buttonsViewPrimaryNonButtonDidTap() {
    router.dismiss() { self.viewModel.complete() }
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
    viewModel.expandSection.sink { [weak self] item in
      guard let self = self else { return }
      let tableUpdate = self.builder.updateSection(&self.sections[item.index],
                                                   with: item.model,
                                                   in: self.tableView,
                                                   at: item.index,
                                                   isExpanded: item.isExpanded,
                                                   isFilled: item.isFilled)
      self.tableView.performBatchUpdates {
        tableUpdate.insertRows.map { self.tableView.insertRows(at: $0, with: .fade) }
        tableUpdate.deleteRows.map { self.tableView.deleteRows(at: $0, with: .fade) }
      } completion: { _ in
        if let nextIndex = item.nextIndex {
          self.viewModel.updateSection(self.sections[nextIndex],
                                       at: nextIndex,
                                       isExpanded: true,
                                       nextSectionIndex: nil)
        }
      }
    }.store(in: &subscriptions)
    
    viewModel.setSectionText.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateSection(&self.sections[$0.indexPath.section],
                                 in: self.tableView,
                                 at: $0.indexPath,
                                 text: $0.text,
                                 fieldIndex: $0.fieldIndex,
                                 isFilled: $0.isFilled)
      self.builder.updateTableFooter(for: self.sections,
                                     in: self.tableView)
    }.store(in: &subscriptions)
    
    viewModel.coutryOfResidenceDidChange.sink { [weak self] in
      guard let self = self else { return }
      let tableUpdate = self.builder.updateSections(&self.sections,
                                                    in: self.tableView,
                                                    countryOfResidenceDidChangeWith: $0.model,
                                                    wasUsResidence: $0.wasUsResidence)
      self.builder.updateTableFooter(for: self.sections,
                                     in: self.tableView)
      self.tableView.performBatchUpdates {
        tableUpdate.deleteRows.map { self.tableView.deleteRows(at: $0, with: .fade) }
        tableUpdate.insertSection.map { self.tableView.insertSections($0, with: .fade) }
        tableUpdate.deleteSection.map { self.tableView.deleteSections($0, with: .fade) }
      }
    }.store(in: &subscriptions)
    
    viewModel.coutryOfResidenceDidSelect.sink { [weak self] in
      guard let self = self else { return }
      let indexSet = self.builder.updateSections(&self.sections,
                                                 in: self.tableView,
                                                 countryOfResidenceDidSelectWith: $0)
      indexSet.map { self.tableView.insertSections($0, with: .fade) }
    }.store(in: &subscriptions)
    
    viewModel.dismiss.sink { [weak self] _ in
      guard let self = self else { return }
      self.router.dismiss() { self.viewModel.complete() }
    }.store(in: &subscriptions)
  }
  
  func getHeaderIndex(_ header: UITableViewHeaderFooterView) -> Int? {
    return sections.indices.firstIndex {
      return tableView.headerView(forSection: $0) === header
    }
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
