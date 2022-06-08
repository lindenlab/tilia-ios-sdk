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
    tableView.register(UserDocumentsSelectDocumentCell.self)
    tableView.register(UserDocumentsSuccessCell.self)
    tableView.estimatedRowHeight = 100
    tableView.estimatedSectionHeaderHeight = 100
    tableView.estimatedSectionFooterHeight = 140
    return tableView
  }()
  
  init(manager: NetworkManager,
       defaultCounty: String,
       onComplete: @escaping (Bool) -> Void,
       onError: ((Error) -> Void)?) {
    let viewModel = UserDocumentsViewModel(manager: manager,
                                           defaultCounty: defaultCounty,
                                           onComplete: onComplete,
                                           onError: onError)
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
    viewModel.complete()
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
                        delegate: self,
                        isUploading: viewModel.uploading.value)
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
                          delegate: self,
                          isUploading: viewModel.uploading.value)
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    builder.updateSuccessCell(cell,
                              for: section,
                              in: tableView)
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
      self.router.showToast(title: L.errorKycTitle,
                            message: L.errorKycMessage)
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
    
    viewModel.setImage.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateSection(&self.section,
                                 at: $0.index,
                                 in: self.tableView,
                                 image: $0.image)
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
    
    viewModel.documentCountryDidChange.sink { [weak self] in
      guard let self = self else { return }
      let tableUpdate = self.builder.updateSection(&self.section,
                                                   documentCountryDidChangeWith: $0.model,
                                                   wasUsResidence: $0.wasUsResidence)
      self.tableView.performBatchUpdates {
        tableUpdate.reload.map { self.tableView.reloadRows(at: $0, with: .fade) }
        tableUpdate.delete.map { self.tableView.deleteRows(at: $0, with: .fade) }
      }
    }.store(in: &subscriptions)
    
    viewModel.isAddressOnDocumentDidChange.sink { [weak self] in
      guard let self = self else { return }
      let tableUpdate = self.builder.updateSection(&self.section,
                                                   isAddressOnDocumentDidChangeWith: $0)
      self.tableView.performBatchUpdates {
        tableUpdate.insert.map { self.tableView.insertRows(at: $0, with: .fade) }
        tableUpdate.delete.map { self.tableView.deleteRows(at: $0, with: .fade) }
      }
    }.store(in: &subscriptions)
    
    viewModel.addDocuments.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateSection(&self.section,
                                 at: $0.index,
                                 in: self.tableView,
                                 didAddDocumentsWith: $0.documentImages)
      self.builder.updateCell(for: self.section,
                              at: $0.index,
                              in: self.tableView,
                              didAddDocumentsWith: $0.documentImages)
    }.store(in: &subscriptions)
    
    viewModel.addDocumentsDidFail.sink { [weak self] _ in
      self?.router.showAddDocumentsDidFailAlert()
    }.store(in: &subscriptions)
    
    viewModel.deleteDocument.sink { [weak self] in
      guard let self = self else { return }
      self.builder.updateSection(&self.section,
                                 at: $0.itemIndex,
                                 in: self.tableView,
                                 didDeleteDocumentAt: $0.documentIndex)
      self.builder.updateCell(for: self.section,
                              at: $0.itemIndex,
                              in: self.tableView,
                              didDeleteDocumentAt: $0.documentIndex)
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
    
    viewModel.successfulUploading.sink { [weak self] in
      guard let self = self, $0 else { return }
      self.section = self.builder.successSection()
      self.tableView.reloadData()
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
