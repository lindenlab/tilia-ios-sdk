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
          let placeholder: String
          var text: String?
          let items: [String]
          let seletedItemIndex: Int?
          
          var fieldContent: TextFieldsCell.FieldContent {
            return (placeholder, text)
          }
        }
        
        struct Photo {
          
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
      view.configure(isPrimaryButtonEnabled: false, delegate: nil) // TODO: - Fix me
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
  
}
