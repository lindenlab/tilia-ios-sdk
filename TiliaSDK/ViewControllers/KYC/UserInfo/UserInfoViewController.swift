//
//  UserInfoViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 02.05.2022.
//

import UIKit
import Combine

final class UserInfoViewController: BaseTableViewController {
  
  override var hideableView: UIView {
    return tableView
  }
  
  private let viewModel: UserInfoViewModelProtocol
  private let router: UserInfoRoutingProtocol
  private let builder = UserInfoSectionBuilder()
  private var subscriptions: Set<AnyCancellable> = []
  private var sections: [UserInfoSectionBuilder.Section] = []
  
  init(manager: NetworkManager,
       onUpdate: ((TLUpdateCallback) -> Void)?,
       onComplete: ((TLCompleteCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    let viewModel = UserInfoViewModel(manager: manager,
                                      onUpdate: onUpdate,
                                      onComplete: onComplete,
                                      onError: onError)
    let router = UserInfoRouter(dataStore: viewModel)
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
    viewModel.load()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.updateTableHeaderHeightIfNeeded()
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
                        at: indexPath,
                        delegate: self)
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return builder.header(for: sections[section],
                          in: tableView,
                          delegate: self,
                          isUploading: viewModel.uploading.value)
  }
  
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return builder.footer(for: sections,
                          in: tableView,
                          at: section,
                          delegate: self,
                          isUploading: viewModel.uploading.value)
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return builder.heightForFooter(in: sections[section])
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    builder.updateSuccessCell(cell, in: tableView)
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
  
  func textFieldsCell(_ cell: TextFieldsCell, didEditAt index: Int) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    viewModel.startEditingEmail(at: indexPath.section)
  }
  
  func textViewWithLink(_ textView: TextViewWithLink, didPressOn link: String) {
    guard TosAcceptModel(str: link) == .privacyPolicy else { return }
    router.showWebView(with: TosAcceptModel.termsOfServiceUrl)
  }
  
}

// MARK: - UserInfoNextButtonCellDelegate

extension UserInfoViewController: UserInfoNextButtonCellDelegate {
  
  func userInfoNextButtonCellButtonDidTap(_ cell: UserInfoNextButtonCell) {
    guard let index = tableView.indexPath(for: cell)?.section else { return }
    viewModel.onNext(for: sections[index], at: index)
  }
  
}

// MARK: - UserInfoUpdateEmailCellDelegate

extension UserInfoViewController: UserInfoUpdateEmailCellDelegate {
  
  func userInfoUpdateEmailCellUpdateButtonDidTap(_ cell: UserInfoUpdateEmailCell) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    viewModel.updateEmail(at: indexPath.section)
  }
  
  func userInfoUpdateEmailCellCancelButtonDidTap(_ cell: UserInfoUpdateEmailCell) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    viewModel.cancelEditingEmail(for: sections[indexPath.section],
                                 at: indexPath.section)
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
    viewModel.upload()
  }
  
  func buttonsViewPrimaryNonButtonDidTap() {
    dismiss(isFromCloseAction: false)
  }
  
}

// MARK: - Private Methods

private extension UserInfoViewController {
  
  func setup() {
    tableView.addClosingKeyboardOnTap()
    tableView.register(UserInfoHeaderView.self)
    tableView.register(UserInfoFooterView.self)
    tableView.register(UserInfoNextButtonCell.self)
    tableView.register(TextFieldCell.self)
    tableView.register(TwoTextFieldsCell.self)
    tableView.register(ThreeTextFieldsCell.self)
    tableView.register(LabelCell.self)
    tableView.register(UserInfoSuccessCell.self)
    tableView.register(UserInfoProcessingCell.self)
    tableView.register(UserInfoImageCell.self)
    tableView.register(UserInfoUpdateEmailCell.self)
    tableView.tableHeaderView = builder.tableHeader()
    tableView.estimatedRowHeight = 150
    tableView.estimatedSectionHeaderHeight = 50
  }
  
  func bind() {
    viewModel.loading.sink { [weak self] in
      guard let self = self else { return }
      $0 ? self.startLoading() : self.stopLoading()
    }.store(in: &subscriptions)
    
    viewModel.content.sink { [weak self] in
      guard let self = self else { return }
      self.sections = self.builder.sections(with: $0)
      self.tableView.reloadData()
    }.store(in: &subscriptions)
    
    viewModel.error.sink { [weak self] in
      guard let self = self else { return }
      if $0.value {
        self.showCancelButton()
      }
      self.router.showToast(title: L.errorKycTitle,
                            message: L.errorKycMessage)
    }.store(in: &subscriptions)
    
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
      tableUpdate.deleteRows.map { self.tableView.deleteRows(at: $0, with: .fade) }
    }.store(in: &subscriptions)
    
    viewModel.coutryOfResidenceDidSelect.sink { [weak self] in
      guard let self = self else { return }
      self.builder.enableSections(&self.sections,
                                  in: self.tableView)
    }.store(in: &subscriptions)
    
    viewModel.nextSection.sink { [weak self] in
      guard let self = self else { return }
      var nextSectionIndex: Int?
      for i in $0 + 1..<self.sections.count {
        if self.sections[i].mode == .expanded {
          break
        } else if self.sections[i].mode == .normal {
          nextSectionIndex = i
          break
        }
      }
      self.viewModel.updateSection(self.sections[$0],
                                   at: $0,
                                   isExpanded: false,
                                   nextSectionIndex: nextSectionIndex)
    }.store(in: &subscriptions)
    
    viewModel.uploading.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateTable(self.tableView,
                               for: self.sections,
                               isUploading: $0)
    }.store(in: &subscriptions)
    
    viewModel.uploadDocuments.sink { [weak self] in
      self?.router.routeToUserDocumentsView()
    }.store(in: &subscriptions)
    
    viewModel.successfulUploading.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateTableHeader(in: self.tableView,
                                     title: L.verifyingIdentity,
                                     subTitle: L.verifyingIdentityMessage)
      self.sections = [self.builder.processingSection()]
      self.tableView.reloadData()
    }.store(in: &subscriptions)
    
    viewModel.processing.sink { [weak self] in
      guard
        let self = self,
        self.builder.updateProcessingSection(for: &self.sections, in: self.tableView) else { return }
      UIView.performWithoutAnimation {
        self.tableView.performBatchUpdates(nil)
      }
    }.store(in: &subscriptions)
    
    viewModel.manualReview.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateTableHeader(in: self.tableView,
                                     title: L.underReview,
                                     subTitle: L.underReviewDescription)
      self.sections = [self.builder.manualReviewSection()]
      self.tableView.reloadData()
    }.store(in: &subscriptions)
    
    viewModel.failedCompleting.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateTableHeader(in: self.tableView,
                                     title: L.willBeInTouch,
                                     subTitle: L.unableToVerifyDescription)
      self.sections = [self.builder.failedSection()]
      self.tableView.reloadData()
    }.store(in: &subscriptions)
    
    viewModel.successfulCompleting.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateTableHeader(in: self.tableView,
                                     title: L.allSet,
                                     subTitle: L.userDocumentsSuccessMessage)
      self.sections = [self.builder.successSection()]
      self.tableView.reloadData()
    }.store(in: &subscriptions)
    
    viewModel.verifyEmail.sink { [weak self] in
      self?.router.routeToVerifyEmailView()
    }.store(in: &subscriptions)
    
    viewModel.emailVerified.sink { [weak self] in
      guard let self = self else { return }
      let tableUpdate = self.builder.reloadEmailSection(for: &self.sections,
                                                        in: self.tableView,
                                                        with: $0.model)
      UIView.performWithoutAnimation {
        tableUpdate.map { self.tableView.reloadSections($0, with: .none) }
      }
      self.router.showToast(title: L.success,
                            message: $0.message,
                            isSuccess: true)
    }.store(in: &subscriptions)
    
    viewModel.didStartEditingEmail.sink { [weak self] in
      guard let self = self else { return }
      let tableUpdate = self.builder.updatesSection(&self.sections[$0.index],
                                                    at: $0.index,
                                                    didStartEditingEmailFor: $0.model)
      self.tableView.performBatchUpdates {
        tableUpdate.insertRows.map { self.tableView.insertRows(at: $0, with: .none) }
        tableUpdate.reloadRows.map { self.tableView.reloadRows(at: $0, with: .none) }
      }
    }.store(in: &subscriptions)
    
    viewModel.didEndEditingEmail.sink { [weak self] in
      guard let self = self else { return }
      let tableUpdate = self.builder.updatesSection(&self.sections[$0.index],
                                                    at: $0.index,
                                                    didEndEditingEmailFor: $0.model)
      self.tableView.performBatchUpdates {
        tableUpdate.deleteRows.map { self.tableView.deleteRows(at: $0, with: .none) }
        tableUpdate.reloadRows.map { self.tableView.reloadRows(at: $0, with: .none) }
      }
    }.store(in: &subscriptions)
    
    viewModel.isSectionFilled.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateSection(&self.sections[$0.index],
                                 in: self.tableView,
                                 at: $0.index,
                                 isFilled: $0.isFilled)
    }.store(in: &subscriptions)
  }
  
  func getHeaderIndex(_ header: UITableViewHeaderFooterView) -> Int? {
    return sections.indices.firstIndex {
      return tableView.headerView(forSection: $0) === header
    }
  }
  
  func dismiss(isFromCloseAction: Bool) {
    router.dismiss { self.viewModel.complete(isFromCloseAction: isFromCloseAction) }
  }
  
  func showCancelButton() {
    showCloseButton(target: self, action: #selector(closeButtonDidTap))
  }
  
  @objc func closeButtonDidTap() {
    dismiss(isFromCloseAction: true)
  }
  
}
