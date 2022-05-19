//
//  UserDocumentsSectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 18.05.2022.
//

import UIKit

struct UserDocumentsSectionBuilder {
  
  typealias TableFooterDelegate = ButtonsViewDelegate
  
  func tableHeader() -> UIView {
    let insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    let view = TitleInfoView(insets: insets)
    view.title = L.almostThere
    view.subTitle = L.userDocumentsMessage
    view.subTitleTextFont = .systemFont(ofSize: 14)
    view.subTitleTextColor = .secondaryTextColor
    return view
  }
  
  func tableFooter(delegate: TableFooterDelegate) -> UIView {
    let primaryButton = PrimaryButtonWithStyle(.titleAndImageCenter)
    primaryButton.setTitle(L.continueTitle,
                           for: .normal)
    primaryButton.setImage(.uploadIcon?.withRenderingMode(.alwaysTemplate),
                           for: .normal)
    primaryButton.isEnabled = false
    
    let nonPrimaryButton = NonPrimaryButtonWithStyle(.imageAndTitleCenter)
    nonPrimaryButton.setTitle(L.goBack,
                              for: .normal)
    nonPrimaryButton.setImage(.leftArrowicon?.withRenderingMode(.alwaysTemplate),
                              for: .normal)
    
    let insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    let view = ButtonsView(primaryButton: primaryButton,
                           nonPrimaryButton: nonPrimaryButton,
                           insets: insets)
    view.delegate = delegate
    return view
  }
  
}
