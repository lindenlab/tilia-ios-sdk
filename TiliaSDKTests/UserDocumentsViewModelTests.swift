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
    
    let networkManager = NetworkManager(serverClient: ServerTestClient())
    let userInfoModel = UserInfoModel(countryOfResidence: CountryModel.usa)
    let viewModel = UserDocumentsViewModel(manager: networkManager,
                                           userInfoModel: userInfoModel,
                                           onComplete: { _ in },
                                           onError: nil)
    
    
    
  }
  
}
