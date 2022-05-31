//
//  UserDocumentsSectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 18.05.2022.
//

import UIKit

struct UserDocumentsSectionBuilder {
  
  typealias CellDelegate = TextFieldsCellDelegate & UserDocumentsPhotoCellDelegate & UserDocumentsSelectCellDelegate
  typealias SectionFooterDelegate = ButtonsViewDelegate
  typealias TableUpdate = (insert: [IndexPath]?, delete: [IndexPath]?, reload: [IndexPath]?)
  
  struct Section {
    
    enum SectionType {
      case documents
      case success
    }
    
    struct Item {
      
      enum Mode {
        
        enum FieldType {
          case document
          case documentCountry
          case isAddressOnDocument
        }
        
        struct Field {
          let type: FieldType
          let placeholder: String?
          var text: String?
          let items: [String]
          var seletedItemIndex: Int?
          
          var fieldContent: TextFieldsCell.FieldContent {
            return (placeholder, text)
          }
        }
        
        enum PhotoType {
          case frontSide
          case backSide
        }
        
        struct Photo {
          let type: PhotoType
          var image: UIImage?
        }
        
        struct Document {
          
        }
        
        case field(Field)
        case photo(Photo)
        case additionalDocuments(Document)
      }
      
      let title: String
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
      cell.configure(title: item.title)
      cell.configure(fieldsContent: [model.fieldContent],
                     description: nil,
                     delegate: delegate)
      cell.configure(inputMode: .picker(items: model.items,
                                        selectedIndex: model.seletedItemIndex))
      return cell
    case let .photo(model):
      let cell = tableView.dequeue(UserDocumentsPhotoCell.self, for: indexPath)
      cell.configure(title: item.title, font: .systemFont(ofSize: 14))
      cell.configure(image: model.image, delegate: delegate)
      return cell
    case let .additionalDocuments(document):
      let cell = tableView.dequeue(UserDocumentsSelectCell.self, for: indexPath)
      cell.configure(delegate: delegate)
      cell.configure(title: item.title,
                     font: .boldSystemFont(ofSize: 16))
      cell.configure(description: L.supportingDocumentsDescription,
                     font: .systemFont(ofSize: 14))
      return cell
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
    let documents = UserDocumentsModel.Document.allCases
    let selectedDocumentIndex = documents.firstIndex { $0 == model.document }
    let field = Section.Item.Mode.Field(type: .document,
                                        placeholder: L.selectDocument,
                                        text: model.document?.description,
                                        items: documents.map { $0.description },
                                        seletedItemIndex: selectedDocumentIndex)
    let items: [Section.Item] = [
      Section.Item(title: L.document, mode: .field(field))
    ]
    return Section(type: .documents, items: items)
  }
  
  func successSection() -> Section {
    return Section(type: .success, items: []) // TODO: - Fix me
  }
  
  func updateSection(_ section: inout Section,
                     at index: Int,
                     text: String?) {
    switch section.items[index].mode {
    case var .field(field):
      let selectedIndex = field.items.firstIndex { $0 == text }
      field.text = text
      field.seletedItemIndex = selectedIndex
      section.items[index].mode = .field(field)
    default:
      break
    }
  }
  
  func updateSection(_ section: inout Section,
                     at index: Int,
                     in tableView: UITableView,
                     image: UIImage?) {
    switch section.items[index].mode {
    case var .photo(photo):
      photo.image = image
      section.items[index].mode = .photo(photo)
      updatePhotoCell(at: index,
                      with: section.items[index],
                      in: tableView)
    default:
      break
    }
  }
  
  func updateSection(_ section: inout Section,
                     didSelectDocumentWith model: UserDocumentsModel) -> [IndexPath] {
    guard let document = model.document else { return [] }
    
    let startIndex = section.items.count
    
    section.items.append(documentFrontSideItem(for: document))
    
    if document != .passport {
      section.items.append(documentBackSideItem(for: document))
    }
    
    let countryItems =  ["USA", "Canada", "Ukraine"]
    section.items.append(documentCountryItem(country: model.documentCountry,
                                             items: countryItems))
    
    if model.isUsResident {
      section.items.append(isAddressOnDocumentItem())
    } else {
      section.items.append(additionalDocumentsItem())
    }
    
    return (startIndex..<section.items.count).map { IndexPath(row: $0, section: 0) }
  }
  
  func updateSection(_ section: inout Section,
                     in tableView: UITableView,
                     documentDidChange document: UserDocumentsModel.Document) -> TableUpdate {
    var tableUpdate: TableUpdate = (nil, nil, nil)
    
    guard let documentFrontSideIndex = documentSideIndex(in: section, for: .frontSide) else { return tableUpdate }
    
    section.items[documentFrontSideIndex] = documentFrontSideItem(for: document)
    updatePhotoCell(at: documentFrontSideIndex,
                    with: section.items[documentFrontSideIndex],
                    in: tableView)
    
    if document == .passport {
      documentSideIndex(in: section, for: .backSide).map {
        section.items.remove(at: $0)
        tableUpdate.delete = [IndexPath(row: $0, section: 0)]
      }
    } else {
      if let index = documentSideIndex(in: section, for: .backSide) {
        section.items[index] = documentBackSideItem(for: document)
        updatePhotoCell(at: index,
                        with: section.items[index],
                        in: tableView)
      } else {
        let index = documentFrontSideIndex + 1
        section.items.insert(documentBackSideItem(for: document), at: index)
        tableUpdate.insert = [IndexPath(row: index, section: 0)]
      }
    }
    
    return tableUpdate
  }
  
  func updateSection(_ section: inout Section,
                     documentCountryDidChangeWith model: UserDocumentsModel,
                     wasUsResidence: Bool) -> TableUpdate {
    var tableUpdate: TableUpdate = (nil, nil, nil)
    
    if model.isUsResident {
      additionalDocumentsIndex(in: section).map {
        section.items[$0] = isAddressOnDocumentItem()
        tableUpdate.reload = [IndexPath(row: $0, section: 0)]
      }
    } else if wasUsResidence, let isAddressOnDocumentIndex = isAddressOnDocumentIndex(in: section) {
      if let _ = additionalDocumentsIndex(in: section) {
        section.items.remove(at: isAddressOnDocumentIndex)
        tableUpdate.delete = [IndexPath(row: isAddressOnDocumentIndex, section: 0)]
      } else {
        section.items[isAddressOnDocumentIndex] = additionalDocumentsItem()
        tableUpdate.reload = [IndexPath(row: isAddressOnDocumentIndex, section: 0)]
      }
    }
    
    return tableUpdate
  }
  
}

// MARK: - Private Methods

private extension UserDocumentsSectionBuilder {
  
  func documentFrontSideItem(for document: UserDocumentsModel.Document) -> Section.Item {
    let photo = Section.Item.Mode.Photo(type: .frontSide, image: document.frontImage)
    return .init(title: L.frontSide, mode: .photo(photo))
  }
  
  func documentBackSideItem(for document: UserDocumentsModel.Document) -> Section.Item {
    let photo = Section.Item.Mode.Photo(type: .backSide, image: document.backImage)
    return .init(title: L.backSide, mode: .photo(photo))
  }
  
  func documentCountryItem(country: String, items: [String]) -> Section.Item {
    let selectedIndex = items.firstIndex { $0 == country }
    let field = Section.Item.Mode.Field(type: .documentCountry,
                                        placeholder: nil,
                                        text: country,
                                        items: items,
                                        seletedItemIndex: selectedIndex)
    return .init(title: L.documentIssuingCountry, mode: .field(field))
  }
  
  func isAddressOnDocumentItem() -> Section.Item {
    let items = BoolModel.allCases
    let field = Section.Item.Mode.Field(type: .isAddressOnDocument,
                                        placeholder: L.selectAnswer,
                                        text: nil,
                                        items: items.map { $0.description },
                                        seletedItemIndex: nil)
    return .init(title: L.isAddressUpToDateDescription, mode: .field(field))
  }
  
  func additionalDocumentsItem() -> Section.Item {
    return .init(title: L.supportingDocuments, mode: .additionalDocuments(.init()))
  }
  
  func updatePhotoCell(at index: Int, with item: Section.Item, in tableView: UITableView) {
    let indexPath = IndexPath(row: index, section: 0)
    guard let cell = tableView.cellForRow(at: indexPath) as? UserDocumentsPhotoCell else { return }
    switch item.mode {
    case let .photo(model):
      cell.configure(image: model.image)
    default:
      break
    }
  }
  
  func documentSideIndex(in section: Section, for type: Section.Item.Mode.PhotoType) -> Int? {
    return section.items.firstIndex {
      if case let .photo(model) = $0.mode, model.type == type {
        return true
      } else {
        return false
      }
    }
  }
  
  func additionalDocumentsIndex(in section: Section) -> Int? {
    return section.items.firstIndex {
      if case .additionalDocuments = $0.mode {
        return true
      } else {
        return false
      }
    }
  }
  
  func isAddressOnDocumentIndex(in section: Section) -> Int? {
    return section.items.firstIndex {
      if case let .field(model) = $0.mode, model.type == .isAddressOnDocument {
        return true
      } else {
        return false
      }
    }
  }
  
}

private extension UserDocumentsModel.Document {
  
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
