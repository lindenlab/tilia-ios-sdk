//
//  NetworkManagerTests.swift
//  NetworkManagerTests
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import XCTest
@testable import TiliaSDK

class NetworkManagerTests: XCTestCase {
  
  var networkManager: NetworkManager!
  
  override func setUpWithError() throws {
    networkManager = NetworkManager(serverClient: ServerTestClient())
  }
  
  func testGetTosRequiredForUserSuccess() {
    TLManager.shared.setToken(UUID().uuidString)
    var isTosSigned = false
    let expectation = XCTestExpectation(description: "testGetTosRequiredForUserSuccess")
    networkManager.getTosRequiredForUser { result in
      expectation.fulfill()
      switch result {
      case .success(let model):
        isTosSigned = model.isTosSigned
      case .failure:
        break
      }
    }
    wait(for: [expectation], timeout: 2)
    XCTAssertFalse(isTosSigned)
  }
  
  func testSignTosForUserSuccess() {
    TLManager.shared.setToken(UUID().uuidString)
    var isSuccess = false
    let expectation = XCTestExpectation(description: "testSignTosForUserSuccess")
    networkManager.signTosForUser { result in
      expectation.fulfill()
      switch result {
      case .success:
        isSuccess = true
      case .failure:
        break
      }
    }
    wait(for: [expectation], timeout: 2)
    XCTAssertTrue(isSuccess)
  }
  
  func testGetUserBalanceByCurrencyCodeSuccess() {
    TLManager.shared.setToken(UUID().uuidString)
    let currency = "TST"
    var balance: Double?
    let expectation = XCTestExpectation(description: "testGetUserBalanceByCurrencyCodeSuccess")
    networkManager.getUserBalanceByCurrencyCode(currency) { result in
      expectation.fulfill()
      switch result {
      case .success(let model):
        balance = model.balance
      case .failure:
        break
      }
    }
    wait(for: [expectation], timeout: 2)
    XCTAssertNotNil(balance)
    XCTAssertEqual(balance, 9701)
  }
  
  func testGetUserBalanceSuccess() {
    TLManager.shared.setToken(UUID().uuidString)
    var balance: BalanceInfoModel?
    let expectation = XCTestExpectation(description: "testGetUserBalanceSuccess")
    networkManager.getUserBalance { result in
      expectation.fulfill()
      switch result {
      case .success(let model):
        balance = model
      case .failure:
        break
      }
    }
    wait(for: [expectation], timeout: 2)
    XCTAssertNotNil(balance)
  }
  
  func testGetUserBalanceByCurrencyCodeFailure() {
    TLManager.shared.setToken(UUID().uuidString)
    let currency = "UAH"
    var currencyError: Error?
    let expectation = XCTestExpectation(description: "testGetUserBalanceByCurrencyCodeFailure")
    networkManager.getUserBalanceByCurrencyCode(currency) { result in
      expectation.fulfill()
      switch result {
      case .success:
        break
      case .failure(let error):
        currencyError = error
      }
    }
    wait(for: [expectation], timeout: 2)
    XCTAssertNotNil(currencyError)
    XCTAssertEqual(currencyError?.localizedDescription, TLError.userBalanceDoesNotExistForCurrency(currency).localizedDescription)
  }
  
  func testGetInvoiceDetailsSuccess() {
    TLManager.shared.setToken(UUID().uuidString)
    var invoice: InvoiceDetailsModel?
    let expectation = XCTestExpectation(description: "testGetInvoiceDetailsSuccess")
    networkManager.getInvoiceDetails(with: "") { result in
      expectation.fulfill()
      switch result {
      case .success(let model):
        invoice = model
      case .failure:
        break
      }
    }
    wait(for: [expectation], timeout: 2)
    XCTAssertNotNil(invoice)
    XCTAssertEqual(invoice?.currency, "TST")
    XCTAssertEqual(invoice?.isEscrow, false)
  }
  
  func testCreateInvoiceSuccess() {
    TLManager.shared.setToken(UUID().uuidString)
    let id = "a55ef8ed-174a-4910-b538-77fc0f0e3d90"
    var invoice: InvoiceModel?
    let expectation = XCTestExpectation(description: "testCreateInvoiceSuccess")
    networkManager.createInvoice(withId: id, isEscrow: false, paymentMethod: nil) { result in
      expectation.fulfill()
      switch result {
      case .success(let model):
        invoice = model
      case .failure:
        break
      }
    }
    wait(for: [expectation], timeout: 2)
    XCTAssertNotNil(invoice)
    XCTAssertEqual(invoice?.invoiceId, id)
  }
  
  func testCreateExcrowInvoiceSuccess() {
    TLManager.shared.setToken(UUID().uuidString)
    let id = "be193753-21fe-4b28-810a-9a04462b6cbf"
    var invoice: InvoiceModel?
    let expectation = XCTestExpectation(description: "testCreateExcrowInvoiceSuccess")
    networkManager.createInvoice(withId: id, isEscrow: true, paymentMethod: nil) { result in
      expectation.fulfill()
      switch result {
      case .success(let model):
        invoice = model
      case .failure:
        break
      }
    }
    wait(for: [expectation], timeout: 2)
    XCTAssertNotNil(invoice)
    XCTAssertEqual(invoice?.invoiceId, id)
  }
  
  func testPayInvoiceSuccess() {
    TLManager.shared.setToken(UUID().uuidString)
    var isSuccess = false
    let expectation = XCTestExpectation(description: "testPayInvoiceSuccess")
    networkManager.payInvoice(withId: "", isEscrow: true) { result in
      expectation.fulfill()
      switch result {
      case .success:
        isSuccess = true
      case .failure:
        break
      }
    }
    wait(for: [expectation], timeout: 2)
    XCTAssertTrue(isSuccess)
  }

}
