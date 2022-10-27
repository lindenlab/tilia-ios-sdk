//
//  UserDocumentsViewModelTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 20.07.2022.
//

import XCTest
import Combine
@testable import TiliaSDK

final class UserDocumentsViewModelTests: XCTestCase {
  
  var subscriptions: Set<AnyCancellable>!
  
  override func setUpWithError() throws {
    subscriptions = []
  }
  
  func testSuccessSetText() {
    var text: String?
    
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let userInfoModel = UserInfoModel(countryOfResidence: .usa)
    let viewModel = UserDocumentsViewModel(manager: networkManager,
                                           userInfoModel: userInfoModel,
                                           onComplete: { _ in },
                                           onError: nil)
    
    let setTextExpectation = XCTestExpectation(description: "testSuccessSetText")
    viewModel.setText.sink {
      text = $0.text
      setTextExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let document = UserDocumentsModel.Document.passport
    viewModel.setText(document.description,
                      for: .init(title: nil,
                                 mode: .field(.init(type: .document,
                                                    placeholder: nil,
                                                    items: []))),
                      at: 0)
    
    wait(for: [setTextExpectation], timeout: 2)
    XCTAssertEqual(text, document.description)
  }
  
  func testSuccessSetImage() {
    var image: UIImage?
    
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let userInfoModel = UserInfoModel(countryOfResidence: .usa)
    let viewModel = UserDocumentsViewModel(manager: networkManager,
                                           userInfoModel: userInfoModel,
                                           onComplete: { _ in },
                                           onError: nil)
    
    let setImageExpectation = XCTestExpectation(description: "testSuccessSetImage")
    viewModel.setDocumentImage.sink {
      image = $0.image
      setImageExpectation.fulfill()
    }.store(in: &subscriptions)
    
    viewModel.setImage(UIImage.logoIcon,
                       for: .init(title: nil,
                                  mode: .photo(.init(type: .frontSide,
                                                     placeholderImage: nil))),
                       at: 0,
                       with: nil)
    
    wait(for: [setImageExpectation], timeout: 2)
    XCTAssertNotNil(image)
  }
  
  func testSuccessSetFiles() {
    var image: UIImage?
    var error: String?
    var deleteIndex: Int?
    
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let userInfoModel = UserInfoModel(countryOfResidence: .usa)
    let viewModel = UserDocumentsViewModel(manager: networkManager,
                                           userInfoModel: userInfoModel,
                                           onComplete: { _ in },
                                           onError: nil)
    
    let setFilesExpectation = XCTestExpectation(description: "testSuccessSetFiles_SetFiles")
    viewModel.addAdditionalDocuments.sink { [weak viewModel] in
      image = $0.documentImages.first
      viewModel?.deleteDocument(forItemIndex: $0.index, atDocumentIndex: 0)
      setFilesExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let chooseFileFailedExpectation = XCTestExpectation(description: "testSuccessSetFiles_ChooseFileFailed")
    viewModel.chooseFileDidFail.sink {
      error = $0
      chooseFileFailedExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let deleteDocumentExpectation = XCTestExpectation(description: "testSuccessSetFiles_DeleteDocument")
    viewModel.deleteAdditionalDocument.sink {
      deleteIndex = $0.documentIndex
      deleteDocumentExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let url = Bundle(for: type(of: self)).url(forResource: "SwiftProgrammingLanguage", withExtension: "pdf")!
    let urls = Array(repeating: url, count: 3)
    viewModel.setFiles(with: urls, at: 0)
    
    let expectations = [
      setFilesExpectation,
      chooseFileFailedExpectation,
      deleteDocumentExpectation
    ]
    
    wait(for: expectations, timeout: 5)
    XCTAssertNotNil(image)
    XCTAssertEqual(error, L.failedToSelectReachedMaxSize)
    XCTAssertEqual(deleteIndex, 0)
  }
  
  func testSuccessSubmit() {
    var uploading: Bool?
    var submittedKyc: SubmittedKycModel?
    
    let submittedKycCallbackExpectation = XCTestExpectation(description: "testSuccessSubmit_SubmittedKycCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let userInfoModel = UserInfoModel(countryOfResidence: .usa)
    let viewModel = UserDocumentsViewModel(manager: networkManager,
                                           userInfoModel: userInfoModel,
                                           onComplete: { submittedKyc = $0; submittedKycCallbackExpectation.fulfill() },
                                           onError: nil)
    
    let uploadingExpectation = XCTestExpectation(description: "testSuccessSubmit_Uploading")
    viewModel.uploading.sink {
      uploading = $0
      uploadingExpectation.fulfill()
    }.store(in: &subscriptions)
    
    let dismissExpectation = XCTestExpectation(description: "testSuccessSubmit_Dismiss")
    viewModel.dismiss.sink { [weak viewModel] in
      viewModel?.complete()
      dismissExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken(UUID().uuidString)
    viewModel.upload()
    
    let expectations = [
      submittedKycCallbackExpectation,
      uploadingExpectation,
      dismissExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(uploading)
    XCTAssertNotNil(submittedKyc)
  }
  
  func testErrorSubmit() {
    var error: Error?
    var errorCallback: TLErrorCallback?
    
    let errorCallbackExpectation = XCTestExpectation(description: "testErrorSubmit_ErrorCallback")
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let userInfoModel = UserInfoModel(countryOfResidence: .usa)
    let viewModel = UserDocumentsViewModel(manager: networkManager,
                                           userInfoModel: userInfoModel,
                                           onComplete: { _ in },
                                           onError: { errorCallback = $0; errorCallbackExpectation.fulfill() })
    
    let errorExpectation = XCTestExpectation(description: "testErrorSubmit_Error")
    viewModel.error.sink {
      error = $0
      errorExpectation.fulfill()
    }.store(in: &subscriptions)
    
    TLManager.shared.setToken("")
    viewModel.upload()
    
    let expectations = [
      errorCallbackExpectation,
      errorExpectation
    ]
    
    wait(for: expectations, timeout: 2)
    XCTAssertNotNil(error)
    XCTAssertNotNil(errorCallback)
  }
  
}
