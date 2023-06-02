//
//  InvoiceRouterTests.swift
//  TiliaSDKTests
//
//  Created by Serhii.Petrishenko on 27.10.2022.
//

import XCTest
@testable import TiliaSDK

final class InvoiceRouterTests: XCTestCase {
  
  func testGetInvoiceDetails() {
    let id = UUID().uuidString
    let router = InvoiceRouter.getInvoiceDetails(id: id)
    TLManager.shared.setToken(UUID().uuidString)
    XCTAssertEqual(router.method, .get)
    XCTAssertNil(router.queryParameters)
    XCTAssertNil(router.bodyParameters)
    XCTAssertEqual(router.service, "invoicing")
    XCTAssertEqual(router.endpoint, "/v2/authorize/invoice/\(id)")
    XCTAssertEqual(router.testData?.count, router.readJSONFromFile("GetInvoiceDetailsResponse")?.count)
    XCTAssertNotNil(try? router.requestHeaders())
    XCTAssertNotNil(try? router.asURLRequest())
  }
  
  func testCreateEscrowInvoice() {
    let model = CreateInvoiceModel(invoiceId: UUID().uuidString, paymentMethods: nil)
    let router = InvoiceRouter.createInvoice(isEscrow: true, model: model)
    TLManager.shared.setToken(UUID().uuidString)
    XCTAssertEqual(router.method, .post)
    XCTAssertNil(router.queryParameters)
    XCTAssertNotNil(router.bodyParameters)
    XCTAssertEqual(router.service, "invoicing")
    XCTAssertEqual(router.endpoint, "/v2/escrow")
    XCTAssertEqual(router.testData?.count, router.readJSONFromFile("CreateEscrowInvoiceResponse")?.count)
    XCTAssertNotNil(try? router.requestHeaders())
    XCTAssertNotNil(try? router.asURLRequest())
  }
  
  func testCreateNonEscrowInvoice() {
    let model = CreateInvoiceModel(invoiceId: UUID().uuidString, paymentMethods: nil)
    let router = InvoiceRouter.createInvoice(isEscrow: false, model: model)
    TLManager.shared.setToken(UUID().uuidString)
    XCTAssertEqual(router.method, .post)
    XCTAssertNil(router.queryParameters)
    XCTAssertNotNil(router.bodyParameters)
    XCTAssertEqual(router.service, "invoicing")
    XCTAssertEqual(router.endpoint, "/v2/invoice")
    XCTAssertEqual(router.testData?.count, router.readJSONFromFile("CreateInvoiceResponse")?.count)
    XCTAssertNotNil(try? router.requestHeaders())
    XCTAssertNotNil(try? router.asURLRequest())
  }
  
  func testPayEscrowInvoice() {
    let id = UUID().uuidString
    let router = InvoiceRouter.payInvoice(id: id, isEscrow: true)
    TLManager.shared.setToken(UUID().uuidString)
    XCTAssertEqual(router.method, .post)
    XCTAssertNil(router.queryParameters)
    XCTAssertNil(router.bodyParameters)
    XCTAssertEqual(router.service, "invoicing")
    XCTAssertEqual(router.endpoint, "/v2/escrow/\(id)/pay")
    XCTAssertEqual(router.testData?.count, router.readJSONFromFile("EmptySuccessResponse")?.count)
    XCTAssertNotNil(try? router.requestHeaders())
    XCTAssertNotNil(try? router.asURLRequest())
  }
  
  func testPayNonEscrowInvoice() {
    let id = UUID().uuidString
    let router = InvoiceRouter.payInvoice(id: id, isEscrow: false)
    TLManager.shared.setToken(UUID().uuidString)
    XCTAssertEqual(router.method, .post)
    XCTAssertNil(router.queryParameters)
    XCTAssertNil(router.bodyParameters)
    XCTAssertEqual(router.service, "invoicing")
    XCTAssertEqual(router.endpoint, "/v2/invoice/\(id)/pay")
    XCTAssertEqual(router.testData?.count, router.readJSONFromFile("EmptySuccessResponse")?.count)
    XCTAssertNotNil(try? router.requestHeaders())
    XCTAssertNotNil(try? router.asURLRequest())
  }
  
  func testGetTransactionDetails() {
    let id = UUID().uuidString
    let router = InvoiceRouter.getTransactionDetails(id: id)
    TLManager.shared.setToken(UUID().uuidString)
    XCTAssertEqual(router.method, .get)
    XCTAssertNil(router.queryParameters)
    XCTAssertNil(router.bodyParameters)
    XCTAssertEqual(router.service, "invoicing")
    XCTAssertEqual(router.endpoint, "/v1/transaction/\(id)")
    XCTAssertEqual(router.testData?.count, router.readJSONFromFile("GetTransactionDetailsBuyerPurchaseResponse")?.count)
    XCTAssertNotNil(try? router.requestHeaders())
    XCTAssertNotNil(try? router.asURLRequest())
  }
  
  func testSendTransactionReceipt() {
    let id = UUID().uuidString
    let email = "test@gmail.com"
    let router = InvoiceRouter.sendTransactionReceipt(id: id, email: email)
    TLManager.shared.setToken(UUID().uuidString)
    XCTAssertEqual(router.method, .post)
    XCTAssertNil(router.queryParameters)
    XCTAssertNotNil(router.bodyParameters)
    XCTAssertEqual(router.service, "invoicing")
    XCTAssertEqual(router.endpoint, "/v1/transaction/\(id)/receipt")
    XCTAssertEqual(router.testData?.count, router.readJSONFromFile("SendTransactionReceiptResponse")?.count)
    XCTAssertNotNil(try? router.requestHeaders())
    XCTAssertNotNil(try? router.asURLRequest())
  }
  
  func testGetTransactionHistory() {
    let model = GetTransactionHistoryModel(limit: 20, offset: 0, sectionType: .pending, accountId: nil)
    let router = InvoiceRouter.getTransactionHistory(model: model)
    TLManager.shared.setToken(UUID().uuidString)
    XCTAssertEqual(router.method, .get)
    XCTAssertNotNil(router.queryParameters)
    XCTAssertNil(router.bodyParameters)
    XCTAssertEqual(router.service, "invoicing")
    XCTAssertEqual(router.endpoint, "/v1/transactions")
    XCTAssertEqual(router.testData?.count, router.readJSONFromFile("GetTransactionHistoryResponse")?.count)
    XCTAssertNotNil(try? router.requestHeaders())
    XCTAssertNotNil(try? router.asURLRequest())
  }
  
}
