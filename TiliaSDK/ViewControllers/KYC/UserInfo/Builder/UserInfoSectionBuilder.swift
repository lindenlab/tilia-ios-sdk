//
//  UserInfoSectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 04.05.2022.
//

import UIKit

struct UserInfoSectionBuilder {
  
  typealias CellDelegate = TextFieldsCellDelegate & UserInfoNextButtonCellDelegate
  typealias SectionHeaderDelegate = UserInfoHeaderViewDelegate
  typealias SectionFooterDelegate = ButtonsViewDelegate
  
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
        default: return .disabled
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
        case stateOrRegion
        case state
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
          case .stateOrRegion: return L.stateOrRegion
          case .state: return L.state
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
          let mask: String?
          
          var fieldsContent: [TextFieldsCell.FieldContent] {
            return fields.map { $0.fieldContent }
          }
          
          init(fields: [Field],
               inputMode: TextFieldCell.InputMode? = nil,
               mask: String? = nil) {
            self.fields = fields
            self.inputMode = inputMode
            self.mask = mask
          }
        }
        
        case fields(Fields)
        case label(String?)
        case button
      }
      
      let type: ItemType?
      var mode: Mode
      let description: String?
      
      init(type: ItemType? = nil, mode: Mode, description: String? = nil) {
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
  }
  
  func numberOfRows(in section: Section) -> Int {
    return section.items.count
  }
  
  func heightForFooter(in section: Section) -> CGFloat {
    switch section.type {
    case .contact: return UITableView.automaticDimension
    default: return .leastNormalMagnitude
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
        model.inputMode.map { newCell.configure(inputMode: $0) }
        model.mask.map { newCell.configure(mask: $0) }
        cell = newCell
      case 2:
        cell = tableView.dequeue(TwoTextFieldsCell.self, for: indexPath)
      case 3:
        cell = tableView.dequeue(ThreeTextFieldsCell.self, for: indexPath)
      default:
        fatalError("For now we do not support more than 3 fields")
      }
      cell.configure(title: item.type?.title ?? "")
      cell.configure(fieldsContent: model.fieldsContent,
                     description: item.description,
                     delegate: delegate)
      return cell
    case let .label(model):
      let cell = tableView.dequeue(LabelCell.self, for: indexPath)
      cell.configure(title: item.type?.title ?? "")
      cell.configure(description: model)
      return cell
    case .button:
      let cell = tableView.dequeue(UserInfoNextButtonCell.self, for: indexPath)
      cell.configure(isButtonEnabled: section.isFilled, delegate: delegate)
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
  
  func footer(for sections: [Section],
              in tableView: UITableView,
              at section: Int,
              delegate: SectionFooterDelegate) -> UIView? {
    switch sections[section].type {
    case .contact:
      let isPrimaryButtonEnabled = isAllSectionsFilled(sections)
      let view = tableView.dequeue(UserInfoFooterView.self)
      view.configure(isPrimaryButtonEnabled: true, // TODO: - Remove this
                     delegate: delegate)
      return view
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
                     in tableView: UITableView,
                     at sectionIndex: Int,
                     isExpanded: Bool,
                     isFilled: Bool) -> [IndexPath] {
    let items: [Section.Item]
    if isExpanded {
      section.mode = .expanded
      switch section.type {
      case .location:
        section.items = itemsForLocationSection(with: model)
      case .personal:
        section.items = itemsForPersonalSection(with: model)
      case .contact:
        section.items = itemsForContactSection(with: model)
      }
      items = section.items
    } else {
      items = section.items
      section.mode = isFilled ? .passed : .normal
      section.items = []
    }
    section.isFilled = isFilled
    
    if let header = tableView.headerView(forSection: sectionIndex) as? UserInfoHeaderView {
      header.configure(mode: section.mode)
    }
    
    return items.enumerated().map { IndexPath(row: $0.offset, section: sectionIndex) }
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
    
    let nextButtonCellIndexPath = IndexPath(row: tableView.numberOfRows(inSection: indexPath.section) - 1,
                                            section: indexPath.section)
    if let nextButtonCell = tableView.cellForRow(at: nextButtonCellIndexPath) as? UserInfoNextButtonCell {
      nextButtonCell.configure(isButtonEnabled: isFilled)
    }
  }
  
  func updateSection(_ section: inout Section,
                     in tableView: UITableView,
                     at indexPath: IndexPath,
                     countryOfResidenceDidChangeWith text: String?) {
    switch section.items[indexPath.row].mode {
    case .label:
      section.items[indexPath.row].mode = .label(text)
      if let cell = tableView.cellForRow(at: indexPath) as? LabelCell {
        cell.configure(description: text)
      }
    default:
      break
    }
  }
  
  func updateSection(_ section: inout Section,
                     in tableView: UITableView,
                     at sectionIndex: Int,
                     mode: UserInfoHeaderView.Mode) {
    section.mode = mode
    if let header = tableView.headerView(forSection: sectionIndex) as? UserInfoHeaderView {
      header.configure(mode: mode)
    }
  }
  
  func updateTableFooter(for sections: [Section],
                         in tableView: UITableView) {
    guard
      let index = sections.lastIndex(where: { $0.type == .contact }),
      let footer = tableView.footerView(forSection: index) as? UserInfoFooterView else { return }
    footer.configure(isPrimaryButtonEnabled: isAllSectionsFilled(sections))
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
                   mode: .fields(countryOfResidenceField)),
      Section.Item(mode: .button)
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
      let mask = "xxx-xx-xxxx"
      let ssnField = Section.Item.Mode.Fields(fields: [.init(placeholder: mask,
                                                             text: model.ssn)],
                                              mask: mask)
      items.append(Section.Item(type: .ssn,
                                mode: .fields(ssnField)))
    }
    
    items.append(Section.Item(mode: .button))
    
    return items
  }
  
  func itemsForContactSection(with model: UserInfoModel) -> [Section.Item] {
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
    
    var items: [Section.Item] = [
      Section.Item(type: .address,
                   mode: .fields(addressField)),
      Section.Item(type: .city,
                   mode: .fields(cityField)),
      Section.Item(type: model.isUsResident ? .state : .stateOrRegion,
                   mode: .fields(regionField)),
      Section.Item(type: .postalCode,
                   mode: .fields(postalCodeField)),
      Section.Item(type: .countryOfResidance,
                   mode: .label(model.countryOfResidence))
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
  
  func isAllSectionsFilled(_ sections: [Section]) -> Bool {
    return sections.filter { $0.isFilled }.count == sections.count
  }
  
}
