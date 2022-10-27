//
//  PossiblyEmpty.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 11.05.2022.
//

import Foundation

protocol PossiblyEmpty {
  var isEmpty: Bool { get }
}

extension PossiblyEmpty {
  
  func toNilIfEmpty() -> Self? {
    return isEmpty ? nil : self
  }
  
}

extension String: PossiblyEmpty { }

extension Int: PossiblyEmpty {
  
  var isEmpty: Bool { return self == 0 }
  
}

extension Double: PossiblyEmpty {
  
  var isEmpty: Bool { return self == 0 }
  
}

extension Array: PossiblyEmpty { }

extension Set: PossiblyEmpty { }

extension Dictionary: PossiblyEmpty { }

extension Optional where Wrapped: PossiblyEmpty {
  
  var isEmpty: Bool {
    switch self {
    case .none: return true
    case .some(let value): return value.isEmpty
    }
  }
  
}
