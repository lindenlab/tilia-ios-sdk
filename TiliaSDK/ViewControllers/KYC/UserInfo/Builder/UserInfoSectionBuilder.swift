//
//  UserInfoSectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 04.05.2022.
//

import UIKit

struct UserInfoSectionBuilder {
  
  typealias CellDelegate = TextFieldsCellDelegate
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
        
        struct ThreeFields {
          let first: TextFieldsCell.FieldsContent
          let second: TextFieldsCell.FieldsContent
          let third: TextFieldsCell.FieldsContent
        }
        
        struct TwoFields {
          let first: TextFieldsCell.FieldsContent
          let second: TextFieldsCell.FieldsContent
        }
        
        struct Field {
          let field: TextFieldsCell.FieldsContent
          let description: String?
          let inputMode: TextFieldCell.InputMode?
        }
        
        case threeFields(ThreeFields)
        case twoFields(TwoFields)
        case field(Field)
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
    case let .field(model):
      let cell = tableView.dequeue(TextFieldCell.self, for: indexPath)
      cell.configure(title: item.type.title)
      cell.configure(fieldsContent: model.field,
                     description: model.description,
                     delegate: delegate)
      model.inputMode.map {
        cell.configure(inputMode: $0)
      }
      return cell
    case let .twoFields(model):
      let cell = tableView.dequeue(TwoTextFieldsCell.self, for: indexPath)
      cell.configure(title: item.type.title)
      cell.configure(fieldsContent: model.first, model.second,
                     description: nil,
                     delegate: delegate)
      return cell
    case let .threeFields(model):
      let cell = tableView.dequeue(TwoTextFieldsCell.self, for: indexPath)
      cell.configure(title: item.type.title)
      cell.configure(fieldsContent: model.first, model.second, model.third,
                     description: nil,
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
    
    let nonPrimaryButton = NonPrimaryButton()
    nonPrimaryButton.setTitle(L.cancel,
                              for: .normal)
    
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
    let items = ["USA", "Canada", "Ukraine"] // TODO: - Remove mock
    let selectedIndex = items.firstIndex { $0 == model.countryOfResidence }
    let countryOfResidenceField = Section.Item.Mode.Field(field: (L.selectCountry, model.countryOfResidence),
                                                          description: nil,
                                                          inputMode: .picker(items: items, selectedIndex: selectedIndex))
    return [
      Section.Item(type: .countryOfResidance, mode: .field(countryOfResidenceField))
    ]
  }
  
  func itemsForPersonalSection(with model: UserInfoModel) -> [Section.Item] {
    let fullNameField = Section.Item.Mode.ThreeFields(first: (L.firstName, model.fullName.first),
                                                      second: (L.middleName, model.fullName.middle),
                                                      third: (L.lastName, model.fullName.last))
    
    let dateOfBirthField = Section.Item.Mode.Field(field: (L.selectDateOfBirth, model.dateOfBirthString),
                                                   description: nil,
                                                   inputMode: .datePicker(selectedDate: model.dateOfBirth))
    
    var items: [Section.Item] = [
      Section.Item(type: .fullName, mode: .threeFields(fullNameField)),
      Section.Item(type: .dateOfBirth, mode: .field(dateOfBirthField))
    ]
    
    if model.isUsResident {
      let ssnField = Section.Item.Mode.Field(field: ("xxx-xx-xxxx", model.ssn),
                                             description: nil,
                                             inputMode: nil)
      items.append(Section.Item(type: .ssn, mode: .field(ssnField)))
    }
    
    return items
  }
  
  func itemsForContactlSection(with model: UserInfoModel) -> [Section.Item] {
    let addressField = Section.Item.Mode.TwoFields(first: (L.streetAddress, model.address.street),
                                                   second: (L.apartment, model.address.apartment))
    
    let cityField = Section.Item.Mode.Field(field: (nil, model.address.city),
                                            description: nil,
                                            inputMode: nil)
    
    let regionField: Section.Item.Mode.Field
    if model.isUsResident {
      let regions = ["Florida", "Montana", "Alaska"] // TODO: - Remove mock
      let selectedRegionIndex = regions.firstIndex { $0 == model.address.region }
      regionField = Section.Item.Mode.Field(field: (L.selectState, model.address.region),
                                            description: nil,
                                            inputMode: .picker(items: regions, selectedIndex: selectedRegionIndex))
    } else {
      regionField = Section.Item.Mode.Field(field: (nil, model.address.region),
                                            description: nil,
                                            inputMode: nil)
    }
    
    let postalCodeField = Section.Item.Mode.Field(field: (nil, model.address.postalCode),
                                                  description: nil,
                                                  inputMode: nil)
    
    let countryOfResidenseLabel = model.countryOfResidence ?? "Here will be country of residence" // TODO: - Add logic
    
    var items: [Section.Item] = [
      Section.Item(type: .address, mode: .twoFields(addressField)),
      Section.Item(type: .city, mode: .field(cityField)),
      Section.Item(type: .region(isUsResident: model.isUsResident), mode: .field(regionField)),
      Section.Item(type: .postalCode, mode: .field(postalCodeField)),
      Section.Item(type: .countryOfResidance, mode: .label(countryOfResidenseLabel))
    ]
    
    if model.isUsResident {
      let canUseAddressFor1099Items = UserInfoModel.CanUseAddressFor1099.allCases.map { $0.rawValue }
      let canUseAddressFor1099SelectedIndex = canUseAddressFor1099Items.firstIndex { $0 == model.canUseAddressFor1099?.rawValue }
      let canUseAddressFor1099Field = Section.Item.Mode.Field(field: (L.selectAnswer, nil),
                                                              description: L.useAddressFor1099Description,
                                                              inputMode: .picker(items: canUseAddressFor1099Items, selectedIndex: canUseAddressFor1099SelectedIndex))
      items.append(Section.Item(type: .useAddressFor1099, mode: .field(canUseAddressFor1099Field)))
    }
    
    return items
  }
  
}
