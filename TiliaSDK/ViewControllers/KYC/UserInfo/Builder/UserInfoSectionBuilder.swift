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
      
      var defaultMode: UserInfoHeaderView.Mode {
        switch self {
        case .location: return .normal
        default: return .normal
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
        
        struct Field {
          let placeholder: String?
          var text: String?
          
          var fieldContent: TextFieldsCell.FieldContent {
            return (placeholder, text)
          }
          
          init(placeholder: String? = nil, text: String? = nil) {
            self.placeholder = placeholder
            self.text = text
          }
        }
        
        struct Fields {
          var fields: [Field]
          let inputMode: TextFieldCell.InputMode?
          
          var fieldsContent: [TextFieldsCell.FieldContent] {
            return fields.map { $0.fieldContent }
          }
          
          init(fields: [Field], inputMode: TextFieldCell.InputMode? = nil) {
            self.fields = fields
            self.inputMode = inputMode
          }
        }
        
        case fields(Fields)
        case label(String)
      }
      
      let type: ItemType
      var mode: Mode
      let description: String?
      
      init(type: ItemType, mode: Mode, description: String? = nil) {
        self.type = type
        self.mode = mode
        self.description = description
      }
    }
    
    let type: SectionType
    var mode: UserInfoHeaderView.Mode
    var isFilled: Bool
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
    case let .fields(model):
      let cell: TextFieldsCell
      switch model.fields.count {
      case 1:
        let newCell = tableView.dequeue(TextFieldCell.self, for: indexPath)
        model.inputMode.map {
          newCell.configure(inputMode: $0)
        }
        cell = newCell
      case 2:
        cell = tableView.dequeue(TwoTextFieldsCell.self, for: indexPath)
      case 3:
        cell = tableView.dequeue(ThreeTextFieldsCell.self, for: indexPath)
      default:
        fatalError("For now we do not support more than 3 fields")
      }
      cell.configure(title: item.type.title)
      cell.configure(fieldsContent: model.fieldsContent,
                     description: item.description,
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
        view.configure(isButtonEnabled: section.isFilled,
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
                     mode: $0.defaultMode,
                     isFilled: false,
                     items: [])
    }
  }
  
  func updateSection(_ section: inout Section,
                     with model: UserInfoModel,
                     isExpanded: Bool,
                     isFilled: Bool) {
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
      section.mode = isFilled ? .passed : .normal
      section.items = []
    }
    section.isFilled = isFilled
  }
  
  func updateSection(_ section: inout Section,
                     in tableView: UITableView,
                     at indexPath: IndexPath,
                     text: String?,
                     fieldIndex: Int,
                     isFilled: Bool) {
    switch section.items[indexPath.row].mode {
    case var .fields(field):
      field.fields[fieldIndex].text = text
      section.items[indexPath.row].mode = .fields(field)
    default:
      break
    }
    section.isFilled = isFilled
    let footer = tableView.footerView(forSection: indexPath.section) as? UserInfoFooterView
    footer?.configure(isButtonEnabled: isFilled)
  }
  
}

// MARK: - Private Methods

private extension UserInfoSectionBuilder {
  
  func itemsForLocationSection(with model: UserInfoModel) -> [Section.Item] {
    let items = ["USA", "Canada", "Ukraine"] // TODO: - Remove mock
    let selectedIndex = items.firstIndex { $0 == model.countryOfResidence }
    let countryOfResidenceField = Section.Item.Mode.Fields(fields: [.init(placeholder: L.selectCountry,
                                                                          text: model.countryOfResidence)],
                                                           inputMode: .picker(items: items,
                                                                              selectedIndex: selectedIndex))
    return [
      Section.Item(type: .countryOfResidance,
                   mode: .fields(countryOfResidenceField))
    ]
  }
  
  func itemsForPersonalSection(with model: UserInfoModel) -> [Section.Item] {
    let fullNameField = Section.Item.Mode.Fields(fields: [.init(placeholder: L.firstName,
                                                                text: model.fullName.first),
                                                          .init(placeholder: L.middleName,
                                                                text: model.fullName.middle),
                                                          .init(placeholder: L.lastName,
                                                                text: model.fullName.last)])
    
    let dateOfBirthField = Section.Item.Mode.Fields(fields: [.init(placeholder: L.selectDateOfBirth,
                                                                   text: model.dateOfBirthString)],
                                                    inputMode: .datePicker(selectedDate: model.dateOfBirth))
    
    var items: [Section.Item] = [
      Section.Item(type: .fullName,
                   mode: .fields(fullNameField)),
      Section.Item(type: .dateOfBirth,
                   mode: .fields(dateOfBirthField))
    ]
    
    if model.isUsResident {
      let ssnField = Section.Item.Mode.Fields(fields: [.init(placeholder: "xxx-xx-xxxx",
                                                             text: model.ssn)])
      items.append(Section.Item(type: .ssn,
                                mode: .fields(ssnField)))
    }
    
    return items
  }
  
  func itemsForContactlSection(with model: UserInfoModel) -> [Section.Item] {
    let addressField = Section.Item.Mode.Fields(fields: [.init(placeholder:L.streetAddress,
                                                               text: model.address.street),
                                                         .init(placeholder:L.apartment,
                                                               text: model.address.apartment)])
    
    let cityField = Section.Item.Mode.Fields(fields: [.init(text: model.address.city)])
    
    let regionField: Section.Item.Mode.Fields
    if model.isUsResident {
      let regions = ["Florida", "Montana", "Alaska"] // TODO: - Remove mock
      let selectedRegionIndex = regions.firstIndex { $0 == model.address.region }
      regionField = Section.Item.Mode.Fields(fields: [.init(placeholder: L.selectState,
                                                            text: model.address.region)],
                                             inputMode: .picker(items: regions,
                                                                selectedIndex: selectedRegionIndex))
      
    } else {
      regionField = Section.Item.Mode.Fields(fields: [.init(text: model.address.region)])
    }
    
    let postalCodeField = Section.Item.Mode.Fields(fields: [.init(text: model.address.postalCode)])
    
    let countryOfResidenseLabel = model.countryOfResidence ?? "Here will be country of residence" // TODO: - Add logic
    
    var items: [Section.Item] = [
      Section.Item(type: .address,
                   mode: .fields(addressField)),
      Section.Item(type: .city,
                   mode: .fields(cityField)),
      Section.Item(type: .region(isUsResident: model.isUsResident),
                   mode: .fields(regionField)),
      Section.Item(type: .postalCode,
                   mode: .fields(postalCodeField)),
      Section.Item(type: .countryOfResidance,
                   mode: .label(countryOfResidenseLabel))
    ]
    
    if model.isUsResident {
      let canUseAddressFor1099Items = UserInfoModel.CanUseAddressFor1099.allCases.map { $0.rawValue }
      let canUseAddressFor1099SelectedIndex = canUseAddressFor1099Items.firstIndex { $0 == model.canUseAddressFor1099?.rawValue }
      
      let canUseAddressFor1099Field = Section.Item.Mode.Fields(fields: [.init(placeholder: L.selectAnswer,
                                                                              text: model.canUseAddressFor1099?.rawValue)],
                                                               inputMode: .picker(items: canUseAddressFor1099Items,
                                                                                  selectedIndex: canUseAddressFor1099SelectedIndex))
      items.append(Section.Item(type: .useAddressFor1099,
                                mode: .fields(canUseAddressFor1099Field),
                                description: L.useAddressFor1099Description))
    }
    
    return items
  }
  
}
