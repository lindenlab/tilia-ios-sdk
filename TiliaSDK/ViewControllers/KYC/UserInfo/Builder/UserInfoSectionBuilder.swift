//
//  UserInfoSectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 04.05.2022.
//

import UIKit

struct UserInfoSectionBuilder {
  
  typealias CellDelegate = NonPrimaryButtonWithImageCellDelegate & TextFieldsCellDelegate
  typealias SectionHeaderDelegate = UserInfoHeaderViewDelegate
  typealias SectionFooterDelegate = UserInfoFooterViewDelegate
  typealias TableFooterDelegate = ButtonsViewDelegate
  
  struct Section {
    
    enum SectionType: CaseIterable {
      case location
      case personal
      case contact
      
      var title: String {
        switch self {
        case .location: return L.location
        case .personal: return L.personal
        case .contact: return L.contact
        }
      }
    }
    
    struct Item {
      
      enum Mode {
        
        struct Button {
          let buttonPlaceholder: String
          let buttonTitle: String?
        }
        
        struct ThreeFields {
          let first: TextFieldsCell.Content
          let second: TextFieldsCell.Content
          let third: TextFieldsCell.Content
        }
        
        struct TwoFields {
          let first: TextFieldsCell.Content
          let second: TextFieldsCell.Content
        }
        
        case button(Button)
        case threeFields(ThreeFields)
        case twoFields(TwoFields)
        case field(TextFieldsCell.Content)
      }
      
      let title: String
      let mode: Mode
    }
    
    let type: SectionType
    var mode: UserInfoHeaderView.Mode
    let isNextButtonEnabled: Bool
    var items: [Item]
    
    var isExpanded: Bool { return mode == .expanded }
    var numberOfRows: Int { return items.count }
    
    var heightForFooter: CGFloat {
      return isExpanded ? UITableView.automaticDimension : .leastNormalMagnitude
    }
  }
  
  func cell(for section: Section,
            in tableView: UITableView,
            at indexPath: IndexPath,
            delegate: CellDelegate) -> UITableViewCell {
    let item = section.items[indexPath.row]
    switch item.mode {
    case let .button(model):
      let cell = tableView.dequeue(NonPrimaryButtonWithImageCell.self, for: indexPath)
      cell.configure(title: item.title)
      cell.configure(buttonPlaceholder: model.buttonPlaceholder,
                     buttonTitle: model.buttonTitle,
                     delegate: delegate)
      return cell
    case let .field(model):
      let cell = tableView.dequeue(TextFieldCell.self, for: indexPath)
      cell.configure(title: item.title)
      cell.configure(content: model, delegate: delegate)
      return cell
    case let .twoFields(model):
      let cell = tableView.dequeue(TwoTextFieldsCell.self, for: indexPath)
      cell.configure(title: item.title)
      cell.configure(content: model.first, model.second,
                     delegate: delegate)
      return cell
    case let .threeFields(model):
      let cell = tableView.dequeue(TwoTextFieldsCell.self, for: indexPath)
      cell.configure(title: item.title)
      cell.configure(content: model.first, model.second, model.third,
                     delegate: delegate)
      return cell
    }
  }
  
  func header(for section: Section,
              in tableView: UITableView,
              delegate: SectionHeaderDelegate) -> UIView {
    let view = tableView.dequeue(UserInfoHeaderView.self)
    view.configure(title: section.type.title,
                   mode: section.mode,
                   delegate: delegate)
    return view
  }
  
  func footer(for section: Section,
              in tableView: UITableView,
              delegate: SectionFooterDelegate) -> UIView? {
    if section.isExpanded {
      let view = tableView.dequeue(UserInfoFooterView.self)
      view.configure(isButtonEnabled: section.isNextButtonEnabled,
                     delegate: delegate)
      return view
    } else {
      return nil
    }
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
    return Section.SectionType.allCases.map {
      return Section(type: $0,
                     mode: .normal,
                     isNextButtonEnabled: false,
                     items: [])
    }
  }
  
  func updateSection(_ section: inout Section, with model: UserInfoModel, isExpanded: Bool) {
    if isExpanded {
      section.mode = .expanded
      switch section.type {
      case .location:
        let button = Section.Item.Mode.Button(buttonPlaceholder: L.selectCountry,
                                              buttonTitle: model.countryOfResidence)
        section.items = [
          Section.Item(title: L.countryOfResidence, mode: .button(button))
        ]
      case .personal:
        let fullNameField = Section.Item.Mode.ThreeFields(first: (L.firstName, model.fullName.first),
                                                          second: (L.middleName, model.fullName.middle),
                                                          third: (L.lastName, model.fullName.last))
        
        let dateOfBirthButton = Section.Item.Mode.Button(buttonPlaceholder: L.selectDateOfBirth,
                                                         buttonTitle: nil) // TODO: - Add here logic
        
        var items: [Section.Item] = [
          Section.Item(title: L.fullName, mode: .threeFields(fullNameField)),
          Section.Item(title: L.dateOfBirth, mode: .button(dateOfBirthButton))
        ]
        
        if model.isUsResident {
          items.append(Section.Item(title: L.ssn, mode: .field(("xxx-xx-xxxx", model.ssn))))
        }
        
        section.items = items
      case .contact: ()
      }
    } else {
      section.mode = .normal
      section.items = []
    }
  }
  
}
