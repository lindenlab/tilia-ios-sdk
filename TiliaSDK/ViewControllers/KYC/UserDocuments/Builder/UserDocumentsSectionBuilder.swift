//
//  UserDocumentsSectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 18.05.2022.
//

import UIKit

struct UserDocumentsSectionBuilder {
  
  typealias CellDelegate = TextFieldsCellDelegate
  typealias SectionFooterDelegate = ButtonsViewDelegate
  
  struct Section {
    
    enum SectionType {
      case documents
      case success
    }
    
    struct Item {
      
      enum ItemType {
        case document
        case documentFrontSide
        case documentBackSide
        case documentCountry
        case isAddressOnDocument
        case supportingDocuments
        
        var title: String {
          switch self {
          case .document: return L.document
          case .documentFrontSide: return L.frontSide
          case .documentBackSide: return L.backSide
          case .documentCountry: return L.documentIssuingCountry
          case .isAddressOnDocument: return L.isAddressUpToDateDescription
          case .supportingDocuments: return L.supportingDocuments
          }
        }
      }
      
      enum Mode {
        
        struct Field {
          let placeholder: String?
          var text: String?
          let items: [String]
          let seletedItemIndex: Int?
          
          var fieldContent: TextFieldsCell.FieldContent {
            return (placeholder, text)
          }
        }
        
        struct Photo {
          let image: UIImage?
          let primaryButtonTitle: String?
          let nonPrimaryButtonTitle: String
          
          init(image: UIImage?,
               primaryButtonTitle: String? = L.captureOnCamera,
               nonPrimaryButtonTitle: String = L.pickFile) {
            self.image = image
            self.primaryButtonTitle = primaryButtonTitle
            self.nonPrimaryButtonTitle = nonPrimaryButtonTitle
          }
        }
        
        struct Document {
          
        }
        
        case field(Field)
        case photo(Photo)
        case additionalDocuments(Document)
      }
      
      let type: ItemType
      var mode: Mode
    }
    
    let type: SectionType
    var items: [Item]
  }
  
  func numberOfRows(in section: Section) -> Int {
    return section.items.count
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
      cell.configure(fieldsContent: [model.fieldContent],
                     description: nil,
                     delegate: delegate)
      cell.configure(inputMode: .picker(items: model.items,
                                        selectedIndex: model.seletedItemIndex))
      return cell
    default: return UITableViewCell()
    }
  }
  
  func header(for section: Section,
              in tableView: UITableView) -> UIView {
    let view = tableView.dequeue(TitleInfoHeaderFooterView.self)
    switch section.type {
    case .documents:
      view.configure(title: L.almostThere, subTitle: L.userDocumentsMessage)
    case .success:
      view.configure(title: L.allSet, subTitle: L.userDocumentsSuccessMessage)
    }
    return view
  }
  
  func footer(for section: Section,
              in tableView: UITableView,
              delegate: SectionFooterDelegate) -> UIView {
    let view = tableView.dequeue(UserDocumentsFooterView.self)
    switch section.type {
    case .documents:
      view.configure(isPrimaryButtonEnabled: false, delegate: delegate)
    case .success:
      view.configure(isPrimaryButtonEnabled: false, delegate: delegate) // TODO: - Fix me
    }
    return view
  }
  
  func documetsSection(with model: UserDocumentsModel) -> Section {
    let documents = DocumentModel.allCases
    let selectedDocumentIndex = documents.firstIndex { $0 == model.document }
    let field = Section.Item.Mode.Field(placeholder: L.selectDocument,
                                        text: model.document?.description,
                                        items: documents.map { $0.description },
                                        seletedItemIndex: selectedDocumentIndex)
    let items: [Section.Item] = [
      Section.Item(type: .document, mode: .field(field))
    ]
    return Section(type: .documents, items: items)
  }
  
  func successSection() -> Section {
    return Section(type: .success, items: [])
  }
  
  func updateSection(_ section: inout Section,
                     at index: Int,
                     text: String?) {
    switch section.items[index].mode {
    case var .field(field):
      field.text = text
      section.items[index].mode = .field(field)
    default:
      break
    }
  }
  
  func updateSection(_ section: inout Section,
                     didSelectDocumentWith model: UserDocumentsModel) -> [IndexPath] {
    guard let document = model.document else { return [] }
    
    section.items.append(documentFrontSideItem(for: document))
    
    documentBackSideItem(for: document).map { section.items.append($0) }
    
    let countryItems =  ["USA", "Canada", "Ukraine"]
    section.items.append(documentCountryItem(country: model.documentCountry,
                                             items: countryItems))
    
    if model.isUsResident {
      section.items.append(isAddressOnDocumentItem())
    }
    
    return (1..<section.items.count).map { IndexPath(row: $0, section: 0) }
  }
  
}

// MARK: - Private Methods

private extension UserDocumentsSectionBuilder {
  
  func documentFrontSideItem(for document: DocumentModel) -> Section.Item {
    return .init(type: .documentFrontSide,
                 mode: .photo(.init(image: document.frontImage)))
  }
  
  func documentBackSideItem(for document: DocumentModel) -> Section.Item? {
    guard document != .passport else { return nil }
    return .init(type: .documentBackSide,
                 mode: .photo(.init(image: document.backImage)))
  }
  
  func documentCountryItem(country: String, items: [String]) -> Section.Item {
    let selectedIndex = items.firstIndex { $0 == country }
    return .init(type: .documentCountry, mode: .field(.init(placeholder: nil,
                                                            text: country,
                                                            items: items,
                                                            seletedItemIndex: selectedIndex)))
  }
  
  func isAddressOnDocumentItem() -> Section.Item {
    let items = BoolModel.allCases
    return .init(type: .isAddressOnDocument, mode: .field(.init(placeholder: L.selectAnswer,
                                                                text: nil,
                                                                items: items.map { $0.description },
                                                                seletedItemIndex: nil)))
  }
  
}

private extension DocumentModel {
  
  var frontImage: UIImage? {
    switch self {
    case .passport: return .passportIcon
    case .driversLicense: return .driversLicenseFrontIcon
    case .identityCard: return .identityCardFrontIcon
    case .residencePermit: return .residencePermitFrontIcon
    }
  }
  
  var backImage: UIImage? {
    switch self {
    case .passport: return nil
    case .driversLicense: return .driversLicenseBackIcon
    case .identityCard: return .identityCardBackIcon
    case .residencePermit: return .residencePermitBackIcon
    }
  }
  
}
