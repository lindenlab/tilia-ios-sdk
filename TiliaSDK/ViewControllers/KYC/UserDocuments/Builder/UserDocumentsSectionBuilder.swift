//
//  UserDocumentsSectionBuilder.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 18.05.2022.
//

import UIKit
import PDFKit

struct UserDocumentsSectionBuilder {
  
  typealias CellDelegate = TextFieldsCellDelegate & UserDocumentsPhotoCellDelegate & UserDocumentsSelectDocumentCellDelegate
  typealias SectionFooterDelegate = ButtonsViewDelegate
  typealias TableUpdate = (insert: [IndexPath]?, delete: [IndexPath]?, reload: [IndexPath]?)
  
  struct Section {
    
    struct Item {
      
      enum Mode {
        
        enum FieldType {
          case document
          case documentCountry
          case isAddressOnDocument
          
          var accessibilityIdentifier: String {
            switch self {
            case .document: return "documentTextField"
            case .documentCountry: return "documentCountryTextField"
            case .isAddressOnDocument: return "isAddressOnDocumentTextField"
            }
          }
        }
        
        struct Field {
          let type: FieldType
          let placeholder: String?
          var text: String?
          let items: [String]
          var seletedItemIndex: Int?
          
          var fieldContent: TextFieldsCell.FieldContent {
            return (placeholder, text, type.accessibilityIdentifier)
          }
        }
        
        enum PhotoType {
          case frontSide
          case backSide
          
          var accessibilityIdentifier: String {
            switch self {
            case .frontSide: return "frontSideChooseButton"
            case .backSide: return "backSideChooseButton"
            }
          }
        }
        
        struct Photo {
          let type: PhotoType
          let placeholderImage: SVGImage?
          var image: UIImage?
        }
        
        case field(Field)
        case photo(Photo)
        case additionalDocuments([UIImage])
      }
      
      let title: String?
      var mode: Mode
    }
    
    var items: [Item]
    var isFilled: Bool
  }
  
  func numberOfRows(in section: Section) -> Int {
    return section.items.count
  }
  
  func cell(for section: Section,
            in tableView: UITableView,
            at indexPath: IndexPath,
            delegate: CellDelegate,
            isUploading: Bool) -> UITableViewCell {
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
      cell.isUserInteractionEnabled = !isUploading
      return cell
    case let .photo(model):
      let cell = tableView.dequeue(UserDocumentsPhotoCell.self, for: indexPath)
      cell.configure(title: item.title)
      cell.configure(delegate: delegate,
                     nonPrimaryButtonAccessibilityIdentifier: model.type.accessibilityIdentifier)
      cell.configure(image: model.image, placeholderView: model.placeholderImage)
      cell.isUserInteractionEnabled = !isUploading
      return cell
    case let .additionalDocuments(images):
      let cell = tableView.dequeue(UserDocumentsSelectDocumentCell.self, for: indexPath)
      cell.configure(title: item.title,
                     documentImages: images,
                     delegate: delegate)
      cell.isUserInteractionEnabled = !isUploading
      return cell
    }
  }
  
  func header(for section: Section,
              in tableView: UITableView) -> UIView {
    let view = tableView.dequeue(TitleInfoHeaderFooterView.self)
    view.configure(title: L.fewMoreThings, subTitle: L.userDocumentsMessage)
    return view
  }
  
  func footer(for section: Section,
              in tableView: UITableView,
              delegate: SectionFooterDelegate,
              isUploading: Bool) -> UIView {
    let view = tableView.dequeue(UserDocumentsFooterView.self)
    view.configure(delegate: delegate)
    view.configure(isPrimaryButtonEnabled: section.isFilled == true)
    view.configure(isLoading: isUploading)
    return view
  }
  
  func documentsSection() -> Section {
    let documents = UserDocumentsModel.Document.allCases
    let field = Section.Item.Mode.Field(type: .document,
                                        placeholder: L.selectDocument,
                                        text: nil,
                                        items: documents.map { $0.description },
                                        seletedItemIndex: nil)
    let items: [Section.Item] = [
      Section.Item(title: L.document, mode: .field(field))
    ]
    return .init(items: items, isFilled: false)
  }
  
  func updateSection(_ section: inout Section,
                     at index: Int,
                     text: String?) {
    guard case var .field(field) = section.items[index].mode else { return }
    let selectedIndex = field.items.firstIndex { $0 == text }
    field.text = text
    field.seletedItemIndex = selectedIndex
    section.items[index].mode = .field(field)
  }
  
  func updateSection(_ section: inout Section,
                     at index: Int,
                     in tableView: UITableView,
                     didSetDocumentImage image: UIImage) {
    guard case var .photo(photo) = section.items[index].mode else { return }
    photo.image = image
    section.items[index].mode = .photo(photo)
    updatePhotoCell(at: index,
                    with: section.items[index],
                    in: tableView)
  }
  
  func updateSection(_ section: inout Section,
                     didSelectDocumentWith model: UserDocumentsModel) -> [IndexPath] {
    guard let document = model.document else { return [] }
    
    let startIndex = section.items.count
    
    section.items.append(documentFrontSideItem(for: document))
    
    if document != .passport {
      section.items.append(documentBackSideItem(for: document))
    }
    
    section.items.append(documentCountryItem(country: model.documentCountry?.name))
    
    if model.isUsDocumentCountry {
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
                     wasUsDocumentCountry: Bool) -> TableUpdate {
    var tableUpdate: TableUpdate = (nil, nil, nil)
    
    if model.isUsDocumentCountry {
      additionalDocumentsIndex(in: section).map {
        section.items[$0] = isAddressOnDocumentItem()
        tableUpdate.reload = [IndexPath(row: $0, section: 0)]
      }
    } else if wasUsDocumentCountry, let isAddressOnDocumentIndex = isAddressOnDocumentIndex(in: section) {
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
  
  func updateSection(_ section: inout Section,
                     isAddressOnDocumentDidChangeWith model: BoolModel?) -> TableUpdate {
    var tableUpdate: TableUpdate = (nil, nil, nil)
    
    if model == .no, additionalDocumentsIndex(in: section) == nil {
      section.items.append(additionalDocumentsItem())
      tableUpdate.insert = [IndexPath(row: section.items.endIndex - 1, section: 0)]
    } else if let index = additionalDocumentsIndex(in: section) {
      section.items.remove(at: index)
      tableUpdate.delete = [IndexPath(row: index, section: 0)]
    }
    
    return tableUpdate
  }
  
  func updateSection(_ section: inout Section,
                     at index: Int,
                     in tableView: UITableView,
                     didAddAdditionalDocumentsWith documentImages: [UIImage]) {
    guard case var .additionalDocuments(additionalDocumentImages) = section.items[index].mode else { return }
    additionalDocumentImages.append(contentsOf: documentImages)
    section.items[index].mode = .additionalDocuments(additionalDocumentImages)
  }
  
  func updateSection(_ section: inout Section,
                     at index: Int,
                     in tableView: UITableView,
                     didDeleteAdditionalDocumentAt documentIndex: Int) {
    guard case var .additionalDocuments(documentImages) = section.items[index].mode else { return }
    documentImages.remove(at: documentIndex)
    section.items[index].mode = .additionalDocuments(documentImages)
  }
  
  func updateSection(_ section: inout Section,
                     in tableView: UITableView,
                     isFilled: Bool) {
    section.isFilled = isFilled
    guard let footer = tableView.footerView(forSection: 0) as? UserDocumentsFooterView else { return }
    footer.configure(isPrimaryButtonEnabled: isFilled)
  }
  
  func updateCell(for section: Section,
                  at index: Int,
                  in tableView: UITableView,
                  didAddAdditionalDocumentsWith documentImages: [UIImage]) {
    guard case let .additionalDocuments(additionalDocumentImages) = section.items[index].mode else { return }
    let indexPath = IndexPath(row: index, section: 0)
    let startIndex = additionalDocumentImages.endIndex - documentImages.count
    let endIndex = additionalDocumentImages.endIndex - 1
    guard let cell = tableView.cellForRow(at: indexPath) as? UserDocumentsSelectDocumentCell else { return }
    cell.configure(documentImages: additionalDocumentImages,
                   insertIndexesRange: startIndex...endIndex)
  }
  
  func updateCell(for section: Section,
                  at index: Int,
                  in tableView: UITableView,
                  didDeleteAdditionalDocumentAt documentIndex: Int) {
    let indexPath = IndexPath(row: index, section: 0)
    guard
      case let .additionalDocuments(documentImages) = section.items[index].mode,
      let cell = tableView.cellForRow(at: indexPath) as? UserDocumentsSelectDocumentCell else { return }
    cell.configure(documentImages: documentImages,
                   deleteIndex: documentIndex)
  }
  
  func updateTable(_ tableView: UITableView,
                   isUploading: Bool) {
    (0..<tableView.numberOfRows(inSection: 0)).forEach {
      guard let cell = tableView.cellForRow(at: .init(row: $0, section: 0)) else { return }
      cell.isUserInteractionEnabled = !isUploading
    }
    guard let footer = tableView.footerView(forSection: 0) as? UserDocumentsFooterView else { return }
    footer.configure(isLoading: isUploading)
  }
  
}

// MARK: - Private Methods

private extension UserDocumentsSectionBuilder {
  
  func documentFrontSideItem(for document: UserDocumentsModel.Document) -> Section.Item {
    let photo = Section.Item.Mode.Photo(type: .frontSide,
                                        placeholderImage: document.frontSvgImage)
    return .init(title: L.frontSide, mode: .photo(photo))
  }
  
  func documentBackSideItem(for document: UserDocumentsModel.Document) -> Section.Item {
    let photo = Section.Item.Mode.Photo(type: .backSide,
                                        placeholderImage: document.backSvgImage)
    return .init(title: L.backSide, mode: .photo(photo))
  }
  
  func documentCountryItem(country: String?) -> Section.Item {
    let countries = CountryModel.countryNames
    let selectedIndex = countries.firstIndex { $0 == country }
    let field = Section.Item.Mode.Field(type: .documentCountry,
                                        placeholder: nil,
                                        text: country,
                                        items: countries,
                                        seletedItemIndex: selectedIndex)
    return .init(title: L.documentIssuingCountry, mode: .field(field))
  }
  
  func isAddressOnDocumentItem() -> Section.Item {
    let items = [""] + BoolModel.allCases.map { $0.description }
    let field = Section.Item.Mode.Field(type: .isAddressOnDocument,
                                        placeholder: L.selectAnswer,
                                        text: nil,
                                        items: items,
                                        seletedItemIndex: nil)
    return .init(title: L.isAddressUpToDateDescription, mode: .field(field))
  }
  
  func additionalDocumentsItem() -> Section.Item {
    return .init(title: L.supportingDocuments, mode: .additionalDocuments(.init()))
  }
  
  func updatePhotoCell(at index: Int, with item: Section.Item, in tableView: UITableView) {
    let indexPath = IndexPath(row: index, section: 0)
    guard
      case let .photo(model) = item.mode,
      let cell = tableView.cellForRow(at: indexPath) as? UserDocumentsPhotoCell else { return }
    cell.configure(image: model.image, placeholderView: model.placeholderImage)
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
  
  var frontSvgImage: SVGImage? {
    switch self {
    case .passport: return UIImage.passportIcon
    case .driversLicense: return UIImage.driversLicenseFrontIcon
    case .identityCard: return UIImage.identityCardFrontIcon
    case .residencePermit: return UIImage.residencePermitFrontIcon
    }
  }
  
  var backSvgImage: SVGImage? {
    switch self {
    case .passport: return nil
    case .driversLicense: return UIImage.driversLicenseBackIcon
    case .identityCard: return UIImage.identityCardBackIcon
    case .residencePermit: return UIImage.residencePermitBackIcon
    }
  }
  
}
