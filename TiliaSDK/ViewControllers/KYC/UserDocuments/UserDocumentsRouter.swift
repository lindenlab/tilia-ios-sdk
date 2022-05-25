//
//  UserDocumentsRouter.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 17.05.2022.
//

import UIKit
import AVFoundation

protocol UserDocumentsRoutingProtocol: RoutingProtocol {
  func routeToImageGalleryView(sourceType: UIImagePickerController.SourceType, delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate)
}

final class UserDocumentsRouter: UserDocumentsRoutingProtocol {
  
  weak var viewController: UIViewController?
  
  func routeToImageGalleryView(sourceType: UIImagePickerController.SourceType, delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
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
  
}
