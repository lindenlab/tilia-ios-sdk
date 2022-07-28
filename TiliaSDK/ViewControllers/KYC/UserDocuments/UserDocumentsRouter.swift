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
  func routeToSelectDocumentsView(delegate: UIDocumentPickerDelegate & UIImagePickerControllerDelegate & UINavigationControllerDelegate)
  func showFailureAlert(with error: String)
}

final class UserDocumentsRouter: UserDocumentsRoutingProtocol {
  
  weak var viewController: UIViewController?
  
  func routeToImagePickerView(sourceType: UIImagePickerController.SourceType, delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
    if sourceType == .camera && AVCaptureDevice.authorizationStatus(for: .video) == .denied {
      showCameraAccessDeniedAlert()
    } else if UIImagePickerController.isSourceTypeAvailable(sourceType) {
      let picker = UIImagePickerController()
      picker.delegate = delegate
      picker.sourceType = sourceType
      viewController?.present(picker, animated: true)
    }
  }
  
  func routeToSelectDocumentsView(delegate: UIDocumentPickerDelegate & UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
    let isPad = UIDevice.current.userInterfaceIdiom == .pad
    let alertController = UIAlertController(title: L.selectFileOrImage,
                                            message: nil,
                                            preferredStyle: isPad ? .alert : .actionSheet)
    
    let takePhotoAction = UIAlertAction(title: L.takePhoto, style: .default) { _ in
      self.routeToImagePickerView(sourceType: .camera, delegate: delegate)
    }
    let selectFromGalleryAction = UIAlertAction(title: L.selectFromGallery, style: .default) { _ in
      self.routeToImagePickerView(sourceType: .photoLibrary, delegate: delegate)
    }
    let selectFromFilesAction = UIAlertAction(title: L.selectFromFiles, style: .default) { _ in
      self.routeToDocumentPickerView(delegate: delegate)
    }
    let cancelAction = UIAlertAction(title: L.cancel, style: .cancel)
    
    alertController.addAction(takePhotoAction)
    alertController.addAction(selectFromGalleryAction)
    alertController.addAction(selectFromFilesAction)
    alertController.addAction(cancelAction)
    
    viewController?.present(alertController, animated: true)
  }
  
  func showFailureAlert(with error: String) {
    let alertController = UIAlertController(title: L.failedToSelect,
                                            message: error,
                                            preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: L.ok, style: .cancel)
    alertController.addAction(cancelAction)
    viewController?.present(alertController, animated: true)
  }
  
}

// MARK: - Private Methods

private extension UserDocumentsRouter {
  
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
  
  func routeToDocumentPickerView(delegate: UIDocumentPickerDelegate) {
    // Supports only pdf files
    let picker: UIDocumentPickerViewController
    if #available(iOS 14, *) {
      picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf],
                                              asCopy: true)
    } else {
      picker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)],
                                              in: .import)
    }
    picker.delegate = delegate
    picker.allowsMultipleSelection = true
    viewController?.present(picker, animated: true)
  }
  
}
