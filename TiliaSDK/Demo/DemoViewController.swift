//
//  ViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import UIKit

final class DemoViewController: UITableViewController {
  
  struct Section {
    let name: String
    let items: [String]
  }
  
  let sections: [Section] = [
    Section(name: "Configurable section", items: ["Is staging", "Set backgroundColor", "Set primaryColor", "Set primaryButtonTextColor", "Set primaryTextColor"]),
    Section(name: "Testable section", items: ["getTosRequiredForUser", "getUserBalanceByCurrency", "TOS flow","Checkout flow"])
  ]
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections[section].items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    if indexPath.section == 0 && indexPath.row == 0 {
      let uiSwitch = UISwitch()
      uiSwitch.isOn = true
      uiSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
      cell.accessoryView = uiSwitch
    } else {
      cell.accessoryView = nil
    }
    cell.textLabel?.text = sections[indexPath.section].items[indexPath.row]
    return cell
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sections[section].name
  }
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return indexPath.section == 0 && indexPath.row == 0 ? nil : indexPath
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    var viewController: UIViewController?
    
    switch (indexPath.section, indexPath.row) {
    case (0, 1):
      viewController = SetBackgroundColorTestViewController()
    case (0, 2):
      viewController = SetPrimaryColorTestViewController()
    case (0, 3):
      viewController = SetPrimaryButtonTextColorTestViewController()
    case (0, 4):
      viewController = SetPrimaryTextColorTestViewController()
    case (1, 0):
      viewController = TosRequiredForUserTestViewController()
    case (1, 1):
      viewController = UserBalanceByCurrencyTestViewController()
    case (1, 2):
      viewController = TosRequiredForUserFlowTestViewController()
    case (1, 3):
      viewController = CheckoutFlowTestViewController()
    default:
      break
    }
    
    guard let viewController = viewController else { return }
    viewController.title = sections[indexPath.section].items[indexPath.row]
    navigationController?.pushViewController(viewController, animated: true)
  }
  
  @objc func switchChanged(_ sender: UISwitch) {
    TLManager.shared.setEnvironment(sender.isOn ? .staging : .production)
  }
  
}

