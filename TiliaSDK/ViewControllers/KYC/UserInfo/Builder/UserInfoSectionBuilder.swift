//
//  UserInfoSectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 04.05.2022.
//

import UIKit

struct UserInfoSectionBuilder {
  
  typealias CellDelegate = NonPrimaryButtonWithImageCellDelegate
  typealias SectionHeaderDelegate = UserInfoHeaderViewDelegate
  typealias SectionFooterDelegate = Any
  typealias TableFooterDelegate = ButtonsViewDelegate
  
  struct Section {
    
    enum Item {
      
      struct Button {
        let title: String
        let buttonPlaceholder: String
        let buttonTitle: String?
      }
      
      struct Field {
        let fieldPlaceholder: String
        let fieldText: String?
      }
      
      struct ThreeFields {
        let first: Field
        let second: Field
        let third: Field
      }
      
      struct TwoFields {
        let first: Field
        let second: Field
      }
      
      case button(Button)
      case threeFields(ThreeFields)
      case twoFields(TwoFields)
      case field(Field)
      
    }
    
    let title: String
    let mode: UserInfoHeaderView.Mode
    let items: [Item]
    
    var isExpanded: Bool { return mode == .expanded }
    
    var numberOfRows: Int { return isExpanded ? items.count : 0 }
  }
  
  func cell(for section: Section,
            in tableView: UITableView,
            at indexPath: IndexPath,
            delegate: CellDelegate) -> UITableViewCell {
    switch section.items[indexPath.row] {
    case let .button(model):
      let cell = tableView.dequeue(NonPrimaryButtonWithImageCell.self, for: indexPath)
      cell.configure(title: model.title,
                     buttonPlaceholder: model.buttonPlaceholder,
                     buttonTitle: model.buttonTitle,
                     delegate: delegate)
      return cell
    default: return UITableViewCell() // TODO: - Add later
    }
  }
  
  func header(for section: Section,
              in tableView: UITableView,
              delegate: SectionHeaderDelegate) -> UIView {
    let view = tableView.dequeue(UserInfoHeaderView.self)
    view.configure(title: section.title,
                   mode: section.mode,
                   delegate: delegate)
    return view
  }
  
  func footer(for section: Section,
              in tableView: UITableView,
              delegate: SectionFooterDelegate) -> UIView? {
    return nil // TODO: - Add logic
  }
  
  func tableHeader() -> UIView {
    let insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    let view = TitleInfoView(insets: insets)
    view.title = L.userInfoTitle
    view.subTitle = L.userInfoMessage
    view.subTitleTextFont = .systemFont(ofSize: 14)
    view.subTitleTextColor = .secondaryTextColor
    return view
  }
  
  func tableFooter(delegate: TableFooterDelegate) -> UIView {
    let primaryButton = PrimaryButtonWithImage(style: .titleAndImageCenter)
    primaryButton.setTitle(L.continueTitle,
                           for: .normal)
    primaryButton.setImage(.rightArrowIcon?.withRenderingMode(.alwaysTemplate),
                           for: .normal)
    primaryButton.imageView?.tintColor = .primaryButtonTextColor
    
    let nonPrimaryButton = NonPrimaryButtonWithImage(style: .imageAndTitleCenter)
    nonPrimaryButton.setTitle(L.cancel,
                              for: .normal)
    nonPrimaryButton.setImage(.rightArrowIcon?.withRenderingMode(.alwaysTemplate),
                              for: .normal)
    nonPrimaryButton.imageView?.tintColor = .primaryTextColor
    nonPrimaryButton.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
    
    let insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    let view = ButtonsView(primaryButton: primaryButton,
                           nonPrimaryButton: nonPrimaryButton,
                           insets: insets)
    view.delegate = delegate
    return view
  }
  
  func sections() -> [Section] {
    return [
      locationSection()
    ]
  }
  
}

// MARK: - Private Methods

private extension UserInfoSectionBuilder {
  
  func locationSection() -> Section {
    let button = Section.Item.Button(title: L.countryOfResidence,
                                     buttonPlaceholder: L.selectCountry,
                                     buttonTitle: nil)
    return Section(title: L.location,
                   mode: .normal,
                   items: [.button(button)])
  }
  
}
