//
//  TLEvent.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 14.04.2022.
//

import Foundation

/// Tilia callback event
public struct TLEvent {
  
  /// Tilia flow
  public enum Flow: String {
    
    /// Terms of Service flow
    case tos
    
    /// Checkout flow
    case checkout
    
    /// KYC flow
    case kyc
    
    /// Transaction Details flow
    case transactionDetails = "txndetails"
    
    /// Transaction History flow
    case transactionHistory = "txnhistory"
    
    /// Payment Selection flow
    case paymentSelection = "payment-selection"
    
  }
  
  /// Tilia action
  public enum Action: String {
    
    /// Appeared error in flow
    case error
    
    /// Error is appeared and flow is closed by user
    case closedByUser = "closed-by-user"
    
    /// Missing required data
    case missingRequiredData = "missing-required-data"
    
    /// Unsupported invoice type
    case unsupportedInvoiceType = "unsupported-invoice-type"
    
    /// Flow is canceled by user
    case cancelledByUser = "cancelled-by-user"
    
    /// Payment processed successfully
    case paymentProcessed = "payment-processed"
    
    /// Flow is completed
    case completed
    
    /// KYC info is submitted successfully
    case kycInfoSubmitted = "kyc-info-submitted"
    
    /// Receipt is sent successfully
    case receiptSent = "receipt-sent"
    
    /// Email is verified successfully
    case emailVerified = "email-verified"
    
    /// Payment method is deleted successfully
    case paymentMethodDeleted = "payment-method-deleted"
    
    /// Payment method is renamed successfully
    case paymentMethodRenamed = "payment-method-renamed"
    
  }
  
  public let flow: Flow
  public let action: Action
  
}

// MARK: - CustomStringConvertible

extension TLEvent: CustomStringConvertible {
  
  public var description: String {
    return "tilia.\(flow.rawValue).\(action.rawValue)"
  }
  
}
