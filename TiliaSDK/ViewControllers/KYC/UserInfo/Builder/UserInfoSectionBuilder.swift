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
      
      enum ItemType {
        case countryOfResidance
        case fullName
        case dateOfBirth
        case ssn
        case address
        case city
        case region(isUsResident: Bool)
        case postalCode
        case useAddressFor1099
        
        var title: String {
          switch self {
          case .countryOfResidance: return L.countryOfResidence
          case .fullName: return L.fullName
          case .dateOfBirth: return L.dateOfBirth
          case .ssn: return L.ssn
          case .address: return L.address
          case .city: return L.city
          case .region(let isUsResident): return isUsResident ? L.state : L.stateOrRegion
          case .postalCode: return L.postalCode
          case .useAddressFor1099: return L.useAddressFor1099
          }
        }
      }
      
      enum Mode {
        
        struct Button {
          let buttonPlaceholder: String
          let buttonTitle: String?
          let description: String?
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
        case label(String)
      }
      
      let type: ItemType
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
      cell.configure(title: item.type.title)
      cell.configure(buttonPlaceholder: model.buttonPlaceholder,
                     buttonTitle: model.buttonTitle,
                     description: model.description,
                     delegate: delegate)
      return cell
    case let .field(model):
      let cell = tableView.dequeue(TextFieldCell.self, for: indexPath)
      cell.configure(title: item.type.title)
      cell.configure(content: model, delegate: delegate)
      return cell
    case let .twoFields(model):
      let cell = tableView.dequeue(TwoTextFieldsCell.self, for: indexPath)
      cell.configure(title: item.type.title)
      cell.configure(content: model.first, model.second,
                     delegate: delegate)
      return cell
    case let .threeFields(model):
      let cell = tableView.dequeue(TwoTextFieldsCell.self, for: indexPath)
      cell.configure(title: item.type.title)
      cell.configure(content: model.first, model.second, model.third,
                     delegate: delegate)
      return cell
    case let .label(model):
      let cell = tableView.dequeue(LabelCell.self, for: indexPath)
      cell.configure(title: item.type.title)
      cell.configure(description: model)
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
    switch section.type {
    case .location, .personal:
      if section.isExpanded {
        let view = tableView.dequeue(UserInfoFooterView.self)
        view.configure(isButtonEnabled: section.isNextButtonEnabled,
                       delegate: delegate)
        return view
      } else {
        return nil
      }
      
    default:
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
    let primaryButton = PrimaryButtonWithStyle(.titleAndImageCenter)
    primaryButton.setTitle(L.continueTitle,
                           for: .normal)
    primaryButton.setImage(.rightArrowIcon?.withRenderingMode(.alwaysTemplate),
                           for: .normal)
    primaryButton.imageView?.tintColor = .primaryButtonTextColor
    
    let nonPrimaryButton = NonPrimaryButtonWithStyle(.imageAndTitleCenter)
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
        section.items = itemsForLocationSection(with: model)
      case .personal:
        section.items = itemsForPersonalSection(with: model)
      case .contact:
        section.items = itemsForContactlSection(with: model)
      }
    } else {
      section.mode = .normal // TODO: - Add here logic for
      section.items = []
    }
  }
  
}

// MARK: - Private Methods

private extension UserInfoSectionBuilder {
  
  func itemsForLocationSection(with model: UserInfoModel) -> [Section.Item] {
    let button = Section.Item.Mode.Button(buttonPlaceholder: L.selectCountry,
                                          buttonTitle: model.countryOfResidence,
                                          description: nil)
    return [
      Section.Item(type: .countryOfResidance, mode: .button(button))
    ]
  }
  
  func itemsForPersonalSection(with model: UserInfoModel) -> [Section.Item] {
    let fullNameField = Section.Item.Mode.ThreeFields(first: (L.firstName, model.fullName.first),
                                                      second: (L.middleName, model.fullName.middle),
                                                      third: (L.lastName, model.fullName.last))
    
    let dateOfBirthButton = Section.Item.Mode.Button(buttonPlaceholder: L.selectDateOfBirth,
                                                     buttonTitle: nil,
                                                     description: nil) // TODO: - Add here logic
    
    var items: [Section.Item] = [
      Section.Item(type: .fullName, mode: .threeFields(fullNameField)),
      Section.Item(type: .dateOfBirth, mode: .button(dateOfBirthButton))
    ]
    
    if model.isUsResident {
      let ssnField = ("xxx-xx-xxxx", model.ssn)
      items.append(Section.Item(type: .ssn, mode: .field(ssnField)))
    }
    
    return items
  }
  
  func itemsForContactlSection(with model: UserInfoModel) -> [Section.Item] {
    let addressField = Section.Item.Mode.TwoFields(first: (L.streetAddress, model.address.street),
                                                   second: (L.apartment, model.address.apartment))
    
    let cityField: (String?, String?) = (nil, model.address.city)
    
    let regionMode: Section.Item.Mode
    if model.isUsResident {
      let stateButton = Section.Item.Mode.Button(buttonPlaceholder: L.selectState,
                                                 buttonTitle: model.address.region,
                                                 description: nil)
      regionMode = .button(stateButton)
    } else {
      let regionField: (String?, String?) = (nil, model.address.region)
      regionMode = .field(regionField)
    }
    
    let postalCode: (String?, String?) = (nil, model.address.postalCode)
    
    let countryOfResidense = model.countryOfResidence ?? "Here will be country of residence" // TODO: - Add logic
    
    var items: [Section.Item] = [
      Section.Item(type: .address, mode: .twoFields(addressField)),
      Section.Item(type: .city, mode: .field(cityField)),
      Section.Item(type: .region(isUsResident: model.isUsResident), mode: regionMode),
      Section.Item(type: .postalCode, mode: .field(postalCode)),
      Section.Item(type: .countryOfResidance, mode: .label(countryOfResidense))
    ]
    
    if model.isUsResident {
      let canUseAddressFor1099Button = Section.Item.Mode.Button(buttonPlaceholder: L.selectAnswer,
                                                                buttonTitle: nil, // TODO: - Add logic
                                                                description: L.useAddressFor1099Description)
      items.append(Section.Item(type: .useAddressFor1099, mode: .button(canUseAddressFor1099Button)))
    }
    
    return items
  }
  
}
