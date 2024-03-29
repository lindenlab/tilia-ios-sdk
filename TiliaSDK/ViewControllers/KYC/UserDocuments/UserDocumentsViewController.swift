//
//  UserDocumentsViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 17.05.2022.
//

import UIKit
import Combine

final class UserDocumentsViewController: BaseTableViewController {
  
  override var hideableView: UIView {
    return tableView
  }
  
  private let viewModel: UserDocumentsViewModelProtocol
  private let router: UserDocumentsRoutingProtocol
  private let builder = UserDocumentsSectionBuilder()
  private var subscriptions: Set<AnyCancellable> = []
  private lazy var section: UserDocumentsSectionBuilder.Section = builder.documentsSection()
  private lazy var pickersDelegate: PickersDelegate = {
    let delegate = PickersDelegate { [weak self] index, image, url in
      guard let self = self else { return }
      self.viewModel.setImage(image,
                              for: self.section.items[index],
                              at: index,
                              with: url)
    } documentPickerHandler: { [weak self] index, urls in
      self?.viewModel.setFiles(with: urls, at: index)
    }
    return delegate
  }()
  
  init(manager: NetworkManager,
       userInfoModel: UserInfoModel,
       onComplete: @escaping (SubmittedKycModel) -> Void,
       onError: ((TLErrorCallback) -> Void)?) {
    let viewModel = UserDocumentsViewModel(manager: manager,
                                           userInfoModel: userInfoModel,
                                           onComplete: onComplete,
                                           onError: onError)
    let router = UserDocumentsRouter()
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
  
  override func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    viewModel.complete()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return builder.numberOfRows(in: self.section)
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return builder.cell(for: section,
                        in: tableView,
                        at: indexPath,
                        delegate: self,
                        isUploading: viewModel.uploading.value)
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return builder.header(for: self.section,
                          in: tableView)
  }
  
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return builder.footer(for: self.section,
                          in: tableView,
                          delegate: self,
                          isUploading: viewModel.uploading.value)
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

// MARK: - UserDocumentsPhotoCellDelegate

extension UserDocumentsViewController: UserDocumentsPhotoCellDelegate {
  
  func userDocumentsPhotoCellPrimaryButtonDidTap(_ cell: UserDocumentsPhotoCell) {
    guard let index = tableView.indexPath(for: cell)?.row else { return }
    pickersDelegate.setIndex(index)
    router.routeToImagePickerView(sourceType: .camera, delegate: pickersDelegate)
  }
  
  func userDocumentsPhotoCellNonPrimaryButtonDidTap(_ cell: UserDocumentsPhotoCell) {
    guard let index = tableView.indexPath(for: cell)?.row else { return }
    pickersDelegate.setIndex(index)
    router.routeToImagePickerView(sourceType: .photoLibrary, delegate: pickersDelegate)
  }
  
}

// MARK: - UserDocumentsSelectCellDelegate

extension UserDocumentsViewController: UserDocumentsSelectDocumentCellDelegate {
  
  func userDocumentsSelectDocumentCellAddButtonDidTap(_ cell: UserDocumentsSelectDocumentCell) {
    guard let index = tableView.indexPath(for: cell)?.row else { return }
    pickersDelegate.setIndex(index)
    router.routeToSelectDocumentsView(delegate: pickersDelegate)
  }
  
  func userDocumentsSelectDocumentCell(_ cell: UserDocumentsSelectDocumentCell, didDeleteItemAt index: Int) {
    guard let itemIndex = tableView.indexPath(for: cell)?.row else { return }
    viewModel.deleteDocument(forItemIndex: itemIndex, atDocumentIndex: index)
  }
  
  func userDocumentsSelectDocumentCell(_ cell: UserDocumentsSelectDocumentCell, didChangeCollectionViewHeight animated: Bool) {
    if animated {
      tableView.performBatchUpdates(nil)
    } else {
      UIView.performWithoutAnimation {
        self.tableView.performBatchUpdates(nil)
      }
    }
  }
  
}

// MARK: - ButtonsViewDelegate

extension UserDocumentsViewController: ButtonsViewDelegate {
  
  func buttonsViewPrimaryButtonDidTap() {
    viewModel.upload()
  }
  
  func buttonsViewPrimaryNonButtonDidTap() {
    router.dismiss { self.viewModel.complete() }
  }
  
}

// MARK: - Private Methods

private extension UserDocumentsViewController {
  
  func setup() {
    tableView.addClosingKeyboardOnTap()
    tableView.register(UserDocumentsPhotoCell.self)
    tableView.register(TitleInfoHeaderFooterView.self)
    tableView.register(UserDocumentsFooterView.self)
    tableView.register(TextFieldCell.self)
    tableView.register(UserDocumentsSelectDocumentCell.self)
    tableView.estimatedRowHeight = 100
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
      self.router.showToast(title: L.errorKycTitle,
                            message: L.errorKycMessage)
    }.store(in: &subscriptions)
    
    viewModel.setText.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateSection(&self.section,
                                 at: $0.index,
                                 text: $0.text)
    }.store(in: &subscriptions)
    
    viewModel.setDocumentImage.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateSection(&self.section,
                                 at: $0.index,
                                 in: self.tableView,
                                 didSetDocumentImage: $0.image)
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
                                                   in: self.tableView,
                                                   documentDidChange: $0)
      self.tableView.performBatchUpdates {
        tableUpdate.insert.map { self.tableView.insertRows(at: $0, with: .fade) }
        tableUpdate.delete.map { self.tableView.deleteRows(at: $0, with: .fade) }
      }
    }.store(in: &subscriptions)
    
    viewModel.shouldAddAdditionalDocuments.sink { [weak self] in
      guard let self = self else { return }
      let tableUpdate = self.builder.updateSection(&self.section,
                                                   shouldAddAdditionalDocuments: $0)
      self.tableView.performBatchUpdates {
        tableUpdate.insert.map { self.tableView.insertRows(at: $0, with: .fade) }
        tableUpdate.delete.map { self.tableView.deleteRows(at: $0, with: .fade) }
      }
    }.store(in: &subscriptions)
    
    viewModel.addAdditionalDocuments.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateSection(&self.section,
                                 at: $0.index,
                                 in: self.tableView,
                                 didAddAdditionalDocumentsWith: $0.documentImages)
      self.builder.updateCell(for: self.section,
                              at: $0.index,
                              in: self.tableView,
                              didAddAdditionalDocumentsWith: $0.documentImages)
    }.store(in: &subscriptions)
    
    viewModel.chooseFileDidFail.sink { [weak self] in
      self?.router.showFailureAlert(with: $0)
    }.store(in: &subscriptions)
    
    viewModel.deleteAdditionalDocument.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateSection(&self.section,
                                 at: $0.itemIndex,
                                 in: self.tableView,
                                 didDeleteAdditionalDocumentAt: $0.documentIndex)
      self.builder.updateCell(for: self.section,
                              at: $0.itemIndex,
                              in: self.tableView,
                              didDeleteAdditionalDocumentAt: $0.documentIndex)
    }.store(in: &subscriptions)
    
    viewModel.fillingContent.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateSection(&self.section,
                                 in: self.tableView,
                                 isFilled: $0)
    }.store(in: &subscriptions)
    
    viewModel.uploading.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateTable(self.tableView,
                               isUploading: $0)
    }.store(in: &subscriptions)
    
    viewModel.dismiss.sink { [weak self] _ in
      guard let self = self else { return }
      self.router.dismiss() { self.viewModel.complete() }
    }.store(in: &subscriptions)
  }
  
  func showCancelButton() {
    showCloseButton(target: self, action: #selector(closeButtonDidTap))
  }
  
  @objc func closeButtonDidTap() {
    router.dismiss()
  }
  
}

private extension UserDocumentsViewController {
  
  final class PickersDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {
    
    private let imagePickerHandler: (Int, UIImage?, URL?) -> Void
    private let documentPickerHandler: (Int, [URL]) -> Void
    private var index: Int!
    
    init(imagePickerHandler: @escaping (Int, UIImage?, URL?) -> Void,
         documentPickerHandler: @escaping (Int, [URL]) -> Void) {
      self.imagePickerHandler = imagePickerHandler
      self.documentPickerHandler = documentPickerHandler
    }
    
    func setIndex(_ index: Int) {
      self.index = index
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      picker.dismiss(animated: true)
      let url = info[.imageURL] as? URL
      let image = info[.originalImage] as? UIImage
      imagePickerHandler(index, image, url)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
      documentPickerHandler(index, urls)
    }
    
  }
  
}
