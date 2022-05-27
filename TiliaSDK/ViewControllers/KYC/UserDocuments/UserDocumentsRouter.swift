//
//  UserDocumentsRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 17.05.2022.
//

import UIKit
import AVFoundation
import CoreServices

protocol UserDocumentsRoutingProtocol: RoutingProtocol {
  func routeToImagePickerView(sourceType: UIImagePickerController.SourceType, delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate)
  func routeToDocumentPickerView(delegate: UIDocumentPickerDelegate)
}

final class UserDocumentsRouter: UserDocumentsRoutingProtocol {
  
  weak var viewController: UIViewController?
  
  func routeToImagePickerView(sourceType: UIImagePickerController.SourceType, delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
    guard AVCaptureDevice.authorizationStatus(for: .video) != .denied else {
      showCameraAccessDeniedAlert()
      return
    }
    guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
    let picker = UIImagePickerController()
    picker.delegate = delegate
    picker.sourceType = sourceType
    viewController?.present(picker, animated: true)
  }
  
  func routeToDocumentPickerView(delegate: UIDocumentPickerDelegate) {
    let picker = UIDocumentPickerViewController(documentTypes: availableDocumentTypes,
                                                in: .import)
    picker.delegate = delegate
    picker.allowsMultipleSelection = true
    viewController?.present(picker, animated: true)
  }
  
}

// MARK: - Private Methods

private extension UserDocumentsRouter {
  
  var availableDocumentTypes: [String] {
    let items: [CFString] = [
      kUTTypePDF
    ]
    return items.map { String($0) }
  }
  
  func showCameraAccessDeniedAlert() {
    let alertController = UIAlertController(title: L.accessToCameraTitle,
                                            message: L.accessToCameraMessage,
                                            preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: L.notNow, style: .default)
    let goToSettingsAction = UIAlertAction(title: L.openSettings, style: .cancel) { _ in
      URL(string: UIApplication.openSettingsURLString).map {
        UIApplication.shared.open($0)
      }
    }
    alertController.addAction(cancelAction)
    alertController.addAction(goToSettingsAction)
    
    viewController?.present(alertController, animated: true)
  }
  
}
