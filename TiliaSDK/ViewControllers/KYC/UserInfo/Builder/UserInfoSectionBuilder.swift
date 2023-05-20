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
  typealias TableUpdate = (insertRows: [IndexPath]?, deleteRows: [IndexPath]?)
  
  struct Section {
    
    enum SectionType {
      case location
      case personal
      case tax
      case contact
      case processing
      case manualReview
      case failed
      case success
      
      static var defaultItems: [SectionType] {
        return [.location, .personal, .tax, .contact]
      }
      
      var headerTitle: String? {
        switch self {
        case .location: return L.location
        case .personal: return L.personal
        case .tax: return L.taxInfo
        case .contact: return L.contact
        default: return nil
        }
      }
      
      var footerHeight: CGFloat {
        switch self {
        case .contact, .processing, .manualReview, .failed, .success:
          return UITableView.automaticDimension
        default:
          return .leastNormalMagnitude
        }
      }
      
      var defaultMode: UserInfoHeaderView.Mode {
        switch self {
        case .location: return .expanded
        default: return .disabled
        }
      }
    }
    
    struct Item {
      
      enum Mode {
        
        enum FieldType {
          case countryOfResidance
          case fullName
          case dateOfBirth
          case ssn
          case signature
          case address
          case city
          case state
          case postalCode
          case useAddressForTax
        }
        
        struct Field {
          let placeholder: String?
          var text: String?
          let accessibilityIdentifier: String?
          
          var fieldContent: TextFieldsCell.FieldContent {
            return (placeholder, text, accessibilityIdentifier)
          }
          
          init(placeholder: String? = nil,
               text: String? = nil,
               accessibilityIdentifier: String?) {
            self.placeholder = placeholder
            self.text = text
            self.accessibilityIdentifier = accessibilityIdentifier
          }
        }
        
        struct Fields {
          let type: FieldType
          var fields: [Field]
          var inputMode: TextFieldCell.InputMode?
          let mask: String?
          
          var fieldsContent: [TextFieldsCell.FieldContent] {
            return fields.map { $0.fieldContent }
          }
          
          init(type: FieldType,
               fields: [Field],
               inputMode: TextFieldCell.InputMode? = nil,
               mask: String? = nil) {
            self.type = type
            self.fields = fields
            self.inputMode = inputMode
            self.mask = mask
          }
        }
        
        enum Processing {
          case processing
          case uploadingInfo
          case dottingInformation
          case verifyingInformation
          case takingWhile
          
          var title: String {
            switch self {
            case .processing: return L.processing
            case .uploadingInfo: return L.uploadingInfo
            case .dottingInformation: return L.dottingInformation
            case .verifyingInformation: return L.verifyingInformation
            case .takingWhile: return L.takingWhile
            }
          }
          
          var onNext: Processing? {
            switch self {
            case .processing: return .uploadingInfo
            case .uploadingInfo: return .dottingInformation
            case .dottingInformation: return .verifyingInformation
            case .verifyingInformation: return .takingWhile
            case .takingWhile: return nil
            }
          }
        }
        
        case fields(Fields)
        case label
        case button
        case processing(Processing)
        case image(UIImage?)
        case success
      }
      
      let title: String?
      var mode: Mode
      let description: String?
      let descriptionTextColor: UIColor?
      let attributedDescription: NSAttributedString?
      let descriptionTextData: TextViewWithLink.TextData?
      let descriptionAdditionalAttributes: [TextViewWithLink.AdditionalAttribute]?
      
      init(mode: Mode,
           title: String? = nil,
           description: String? = nil,
           descriptionTextColor: UIColor? = nil,
           attributedDescription: NSAttributedString? = nil,
           descriptionTextData: TextViewWithLink.TextData? = nil,
           descriptionAdditionalAttributes: [TextViewWithLink.AdditionalAttribute]? = nil) {
        self.title = title
        self.mode = mode
        self.description = description
        self.descriptionTextColor = descriptionTextColor
        self.attributedDescription = attributedDescription
        self.descriptionTextData = descriptionTextData
        self.descriptionAdditionalAttributes = descriptionAdditionalAttributes
      }
    }
    
    let type: SectionType
    var mode: UserInfoHeaderView.Mode?
    var isFilled: Bool?
    var items: [Item]
  }
  
  func numberOfRows(in section: Section) -> Int {
    return section.mode == .expanded ? section.items.count : 0
  }
  
  func heightForFooter(in section: Section) -> CGFloat {
    return section.type.footerHeight
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
      cell.configure(title: item.title)
      cell.configure(fieldsContent: model.fieldsContent,
                     description: item.description,
                     attributedDescription: item.attributedDescription,
                     descriptionTextData: item.descriptionTextData,
                     descriptionAdditionalAttributes: item.descriptionAdditionalAttributes,
                     delegate: delegate)
      return cell
    case .label:
      let cell = tableView.dequeue(LabelCell.self, for: indexPath)
      cell.configure(title: item.title)
      cell.configure(description: item.description,
                     attributedDescription: item.attributedDescription,
                     textColor: item.descriptionTextColor ?? .secondaryTextColor,
                     textData: item.descriptionTextData,
                     delegate: delegate)
      return cell
    case .button:
      let cell = tableView.dequeue(UserInfoNextButtonCell.self, for: indexPath)
      cell.configure(delegate: delegate)
      cell.configure(isButtonEnabled: section.isFilled ?? false)
      return cell
    case let .processing(model):
      let cell = tableView.dequeue(UserInfoProcessingCell.self, for: indexPath)
      cell.configure(title: model.title)
      return cell
    case let .image(image):
      let cell = tableView.dequeue(UserInfoImageCell.self, for: indexPath)
      cell.configure(image: image)
      return cell
    case .success:
      let cell = tableView.dequeue(UserInfoSuccessCell.self, for: indexPath)
      return cell
    }
  }
  
  func header(for section: Section,
              in tableView: UITableView,
              delegate: SectionHeaderDelegate,
              isUploading: Bool) -> UIView? {
    guard let mode = section.mode else { return nil }
    let view = tableView.dequeue(UserInfoHeaderView.self)
    view.configure(title: section.type.headerTitle,
                   delegate: delegate)
    view.configure(mode: mode, animated: false)
    view.isUserInteractionEnabled = !isUploading
    return view
  }
  
  func footer(for sections: [Section],
              in tableView: UITableView,
              at section: Int,
              delegate: SectionFooterDelegate,
              isUploading: Bool) -> UIView? {
    switch sections[section].type {
    case .contact:
      let isPrimaryButtonEnabled = isAllSectionsFilled(sections)
      let view = tableView.dequeue(UserInfoFooterView.self)
      view.configure(isDividerHidden: false,
                     isPrimaryButtonHidden: false,
                     nonPrimaryButtonTitle: L.cancel,
                     nonPrimaryButtonAccessibilityIdentifier: nil,
                     delegate: delegate)
      view.configure(isPrimaryButtonEnabled: isPrimaryButtonEnabled)
      view.configure(isLoading: isUploading)
      return view
    case .processing, .manualReview, .failed:
      let view = tableView.dequeue(UserInfoFooterView.self)
      view.configure(isDividerHidden: true,
                     isPrimaryButtonHidden: true,
                     nonPrimaryButtonTitle: L.close,
                     nonPrimaryButtonAccessibilityIdentifier: "closeButton",
                     delegate: delegate)
      return view
    case .success:
      let view = tableView.dequeue(UserInfoFooterView.self)
      view.configure(isDividerHidden: true,
                     isPrimaryButtonHidden: true,
                     nonPrimaryButtonTitle: L.done,
                     nonPrimaryButtonAccessibilityIdentifier: "doneButton",
                     delegate: delegate)
      return view
    default:
      return nil
    }
  }
  
  func tableHeader() -> UIView {
    let insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    let view = TitleInfoView(insets: insets)
    view.title = L.verifyYourIdentity
    view.subTitle = L.userInfoMessage
    view.subTitleTextFont = .systemFont(ofSize: 14)
    view.subTitleTextColor = .secondaryTextColor
    return view
  }
  
  func sections(with model: UserDetailInfoModel) -> [Section] {
    return Section.SectionType.defaultItems.map {
      return Section(type: $0,
                     mode: $0.defaultMode,
                     isFilled: false,
                     items: defaultItems(for: $0))
    }
  }
  
  func processingSection() -> Section {
    return .init(type: .processing,
                 items: [.init(mode: .processing(.processing))])
  }
  
  func manualReviewSection() -> Section {
    return .init(type: .manualReview,
                 items: [.init(mode: .image(.reviewIcon))])
  }
  
  func failedSection() -> Section {
    return .init(type: .failed,
                 items: [.init(mode: .image(.openEnvelopeIcon))])
  }
  
  func successSection() -> Section {
    return .init(type: .success,
                 items: [.init(mode: .success)])
  }
  
  func updateSection(_ section: inout Section,
                     with model: UserInfoModel,
                     in tableView: UITableView,
                     at sectionIndex: Int,
                     isExpanded: Bool,
                     isFilled: Bool) -> TableUpdate {
    let mode: UserInfoHeaderView.Mode = isExpanded ? .expanded : isFilled ? .passed : .normal
    if section.items.isEmpty {
      section.items = items(for: section.type, with: model)
    }
    updateSection(&section,
                  in: tableView,
                  at: sectionIndex,
                  mode: mode)
    let indexPaths = section.items.enumerated().map { IndexPath(row: $0.offset, section: sectionIndex) }
    var tableUpdate: TableUpdate = (nil, nil)
    if isExpanded {
      tableUpdate.insertRows = indexPaths
    } else {
      tableUpdate.deleteRows = indexPaths
    }
    return tableUpdate
  }
  
  func updateSection(_ section: inout Section,
                     in tableView: UITableView,
                     at indexPath: IndexPath,
                     text: String?,
                     fieldIndex: Int,
                     isFilled: Bool) {
    guard case var .fields(field) = section.items[indexPath.row].mode else { return }
    field.fields[fieldIndex].text = text
    if let inputMode = field.inputMode, case let .picker(items, _) = inputMode {
      let selectedIndex = items.firstIndex { $0 == text }
      field.inputMode = .picker(items: items, selectedIndex: selectedIndex)
    }
    section.items[indexPath.row].mode = .fields(field)
    
    section.isFilled = isFilled
    
    section.items.firstIndex {
      if case .button = $0.mode {
        return true
      } else {
        return false
      }
    }.map {
      let nextButtonCellIndexPath = IndexPath(row: $0,
                                              section: indexPath.section)
      if let nextButtonCell = tableView.cellForRow(at: nextButtonCellIndexPath) as? UserInfoNextButtonCell {
        nextButtonCell.configure(isButtonEnabled: isFilled)
      }
    }
  }
  
  func enableSections(_ sections: inout [Section], in tableView: UITableView) {
    for (index, section) in sections.enumerated() where section.mode == .disabled {
      updateSection(&sections[index],
                    in: tableView,
                    at: index,
                    mode: .normal)
    }
  }
  
  func updateSections(_ sections: inout [Section],
                      in tableView: UITableView,
                      countryOfResidenceDidChangeWith model: UserInfoModel,
                      wasUsResidence: Bool) -> TableUpdate {
    var indexPaths: [IndexPath] = []
    sections.enumerated().forEach {
      switch $1.type {
      case .tax where model.isUsResident || wasUsResidence, .contact:
        let deletePaths = setSectionToDefaultIfNeeded(&sections[$0],
                                                      in: tableView,
                                                      at: $0)
        indexPaths.append(contentsOf: deletePaths ?? [])
      default: break
      }
    }
    return (nil, indexPaths.toNilIfEmpty())
  }
  
  func updateTableFooter(for sections: [Section],
                         in tableView: UITableView) {
    guard
      let index = sections.firstIndex(where: { $0.type == .contact }),
      let footer = tableView.footerView(forSection: index) as? UserInfoFooterView else { return }
    footer.configure(isPrimaryButtonEnabled: isAllSectionsFilled(sections))
  }
  
  func updateSuccessCell(_ cell: UITableViewCell,
                         in tableView: UITableView) {
    guard let successCell = cell as? UserInfoSuccessCell else { return }
    successCell.startAnimatingIfNeeded()
  }
  
  func updateTable(_ tableView: UITableView,
                   for sections: [Section],
                   isUploading: Bool) {
    sections.enumerated().forEach {
      if let header = tableView.headerView(forSection: $0.offset) {
        header.isUserInteractionEnabled = !isUploading
      }
      if $0.element.type == .contact,
         let footer = tableView.footerView(forSection: $0.offset) as? UserInfoFooterView {
        footer.configure(isLoading: isUploading)
      }
    }
  }
  
  func updateProcessingSection(for sections: inout [Section],
                               in tableView: UITableView) -> Bool {
    guard
      let index = sections.firstIndex(where: { $0.type == .processing }),
      case let .processing(model) = sections[index].items.first?.mode,
      let nextItem = model.onNext else { return false }
    sections[index].items[0].mode = .processing(nextItem)
    let indexPath = IndexPath(row: 0, section: 0)
    if let cell = tableView.cellForRow(at: indexPath) as? UserInfoProcessingCell {
      cell.configure(title: nextItem.title)
    }
    return true
  }
  
  func updateTableHeader(in tableView: UITableView,
                         title: String,
                         subTitle: String) {
    guard let header = tableView.tableHeaderView as? TitleInfoView else { return }
    header.title = title
    header.subTitle = subTitle
    tableView.updateTableHeaderHeightIfNeeded()
  }
  
}

// MARK: - Private Methods

private extension UserInfoSectionBuilder {
  
  func defaultItems(for type: Section.SectionType) -> [Section.Item] {
    switch type {
    case .location: return itemsForLocationSection(with: nil)
    default: return []
    }
  }
  
  func items(for type: Section.SectionType, with model: UserInfoModel) -> [Section.Item] {
    switch type {
    case .location: return itemsForLocationSection(with: model)
    case .personal: return itemsForPersonalSection(with: model)
    case .tax: return itemsForTaxSection(with: model)
    case .contact: return itemsForContactSection(with: model)
    default: return []
    }
  }
  
  func itemsForLocationSection(with model: UserInfoModel?) -> [Section.Item] {
    let countries = CountryModel.countryNames
    let selectedIndex = countries.firstIndex { $0 == model?.countryOfResidence?.name }
    let countryOfResidenceField = Section.Item.Mode.Fields(type: .countryOfResidance,
                                                           fields: [.init(placeholder: L.selectCountry,
                                                                          text: model?.countryOfResidence?.name,
                                                                          accessibilityIdentifier: "countryOfResidenceTextField")],
                                                           inputMode: .picker(items: countries,
                                                                              selectedIndex: selectedIndex))
    return [
      Section.Item(mode: .fields(countryOfResidenceField),
                   title: L.countryOfResidence),
      Section.Item(mode: .button)
    ]
  }
  
  func itemsForPersonalSection(with model: UserInfoModel) -> [Section.Item] {
    let fullNameField = Section.Item.Mode.Fields(type: .fullName,
                                                 fields: [.init(placeholder: L.firstName,
                                                                text: model.fullName.first,
                                                                accessibilityIdentifier: "firstNameTextField"),
                                                          .init(placeholder: L.middleName,
                                                                text: model.fullName.middle,
                                                                accessibilityIdentifier: "middleNameTextField"),
                                                          .init(placeholder: L.lastName,
                                                                text: model.fullName.last,
                                                                accessibilityIdentifier: "lastNameTextField")])
    
    let dateOfBirthField = Section.Item.Mode.Fields(type: .dateOfBirth,
                                                    fields: [.init(placeholder: L.selectDateOfBirth,
                                                                   text: model.dateOfBirthString,
                                                                   accessibilityIdentifier: "dateOfBirthTextField")],
                                                    inputMode: .datePicker(selectedDate: model.dateOfBirth))
    
    return [
      Section.Item(mode: .fields(fullNameField),
                   title: L.fullName),
      Section.Item(mode: .fields(dateOfBirthField),
                   title: L.dateOfBirth),
      Section.Item(mode: .button)
    ]
  }
  
  func itemsForTaxSection(with model: UserInfoModel) -> [Section.Item] {
    var items: [Section.Item] = []
    if model.isUsResident {
      let ssnFieldMask = "xxx-xx-xxxx"
      let ssnField = Section.Item.Mode.Fields(type: .ssn,
                                              fields: [.init(placeholder: ssnFieldMask,
                                                             text: model.tax.ssn,
                                                             accessibilityIdentifier: "ssnTextField")],
                                              mask: ssnFieldMask)
      items.append(Section.Item(mode: .fields(ssnField),
                                title: L.ssn))
    }
    let certificationMessage = certificationMessage(title: model.isUsResident ? L.certificationUsMessage : L.certificationNonUsMessage,
                                                    subTitle: model.isUsResident ? nil : L.certificationNonUsAdditionalMessage)
    let signatureField = Section.Item.Mode.Fields(type: .signature,
                                                  fields: [.init(placeholder: L.yourFullName,
                                                                 text: model.tax.signature,
                                                                 accessibilityIdentifier: "signatureTextField")])
    let signatureMessage = signatureMessage(title: L.signatureDescription,
                                            subTitle: L.taxPurposesMessage,
                                            link: TosAcceptModel.privacyPolicy.description)
    items.append(contentsOf: [
      Section.Item(mode: .label,
                   title: model.isUsResident ? L.certificationUsTitle : L.certificationNonUsTitle,
                   attributedDescription: certificationMessage),
      Section.Item(mode: .fields(signatureField),
                   title: model.isUsResident ? L.signatureUs : L.signature,
                   descriptionTextData: signatureMessage.0,
                   descriptionAdditionalAttributes: [signatureMessage.1]),
      Section.Item(mode: .button)
    ])
    return items
  }
  
  func itemsForContactSection(with model: UserInfoModel) -> [Section.Item] {
    let addressField = Section.Item.Mode.Fields(type: .address,
                                                fields: [.init(placeholder:L.streetAddress,
                                                               text: model.address.street,
                                                               accessibilityIdentifier: "streetTextField"),
                                                         .init(placeholder:L.apartment,
                                                               text: model.address.apartment,
                                                               accessibilityIdentifier: "apartmentTextField")])
    
    let cityField = Section.Item.Mode.Fields(type: .city,
                                             fields: [.init(text: model.address.city,
                                                            accessibilityIdentifier: "cityTextField")])
    
    let regionField: Section.Item.Mode.Fields
    let regionFieldAccessibilityIdentifier = "stateTextField"
    let hasStates: Bool
    if let states = model.countryOfResidence?.states {
      let regions = states.compactMap { $0.name }
      let selectedRegionIndex = regions.firstIndex { $0 == model.address.region.name }
      hasStates = true
      regionField = Section.Item.Mode.Fields(type: .state,
                                             fields: [.init(placeholder: L.selectState,
                                                            text: model.address.region.name,
                                                            accessibilityIdentifier: regionFieldAccessibilityIdentifier)],
                                             inputMode: .picker(items: regions,
                                                                selectedIndex: selectedRegionIndex))
      
    } else {
      hasStates = false
      regionField = Section.Item.Mode.Fields(type: .state,
                                             fields: [.init(text: model.address.region.name,
                                                            accessibilityIdentifier: regionFieldAccessibilityIdentifier)])
    }
    
    let postalCodeField = Section.Item.Mode.Fields(type: .postalCode,
                                                   fields: [.init(text: model.address.postalCode,
                                                                  accessibilityIdentifier: "postalCodeTextField")])
    
    var items: [Section.Item] = [
      Section.Item(mode: .fields(addressField),
                   title: L.permanentResidenceAddress),
      Section.Item(mode: .fields(cityField),
                   title: L.city),
      Section.Item(mode: .fields(regionField),
                   title: hasStates ? L.state : L.stateOrRegion),
      Section.Item(mode: .fields(postalCodeField),
                   title: L.postalCode),
      Section.Item(mode: .label,
                   title: L.countryOfResidence,
                   description: model.countryOfResidence?.name)
    ]
    
    let canUseAddressForTaxItems = BoolModel.allCases
    let canUseAddressForTaxSelectedIndex = canUseAddressForTaxItems.firstIndex { $0 == model.address.canUseAddressForTax }
    let pickerItems = [""] + canUseAddressForTaxItems.map { $0.description }
    
    let canUseAddressForTaxField = Section.Item.Mode.Fields(type: .useAddressForTax,
                                                            fields: [.init(placeholder: L.selectAnswer,
                                                                           text: model.address.canUseAddressForTax?.description,
                                                                           accessibilityIdentifier: "useAddressForTaxTextField")],
                                                            inputMode: .picker(items: pickerItems,
                                                                               selectedIndex: canUseAddressForTaxSelectedIndex))
    items.append(Section.Item(mode: .fields(canUseAddressForTaxField),
                              title: L.useAddressForTax,
                              description: model.isUsResident ? L.useAddressForTaxUsDescription : nil))
    
    return items
  }
  
  func isAllSectionsFilled(_ sections: [Section]) -> Bool {
    return sections.filter { $0.isFilled ?? false }.count == sections.count
  }
  
  func updateSection(_ section: inout Section,
                     in tableView: UITableView,
                     at sectionIndex: Int,
                     mode: UserInfoHeaderView.Mode) {
    section.mode = mode
    if let header = tableView.headerView(forSection: sectionIndex) as? UserInfoHeaderView {
      header.configure(mode: mode, animated: true)
    }
  }
  
  func setSectionToDefaultIfNeeded(_ section: inout Section,
                                   in tableView: UITableView,
                                   at sectionIndex: Int) -> [IndexPath]? {
    let indexPaths = section.mode == .expanded ? section.items.enumerated().map { IndexPath(row: $0.offset, section: sectionIndex) } : nil
    section.isFilled = false
    section.items = []
    updateSection(&section,
                  in: tableView,
                  at: sectionIndex,
                  mode: .normal)
    return indexPaths
  }
  
  func certificationMessage(title: String, subTitle: String?) -> NSAttributedString {
    let newStr = [title, subTitle].compactMap { $0 }.joined(separator: "\n")
    let attributes: [NSAttributedString.Key: Any] = [
      .font: UIFont.systemFont(ofSize: 14),
      .foregroundColor: UIColor.secondaryTextColor
    ]
    let mutableStr = NSMutableAttributedString(string: newStr,
                                               attributes: attributes)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.headIndent = 16
    mutableStr.addAttribute(.paragraphStyle,
                            value: paragraphStyle,
                            range: mutableStr.mutableString.range(of: title))
    return mutableStr
  }
  
  func signatureMessage(title: String, subTitle: String, link: String) -> (TextViewWithLink.TextData, TextViewWithLink.AdditionalAttribute) {
    let newStr = [title, subTitle].joined(separator: "\n\n")
    let textData: TextViewWithLink.TextData = (newStr, [link])
    let additionalAttribute: TextViewWithLink.AdditionalAttribute = (subTitle, .secondaryTextColor, .systemFont(ofSize: 14))
    return (textData, additionalAttribute)
  }
  
}
