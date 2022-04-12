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
    Section(name: "Configurable section", items: ["Is staging", "Use mocks (only for UI Tests)", "Set colors"]),
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
    if indexPath.section == 0 {
      if indexPath.row == 0 || indexPath.row == 1 {
        let uiSwitch = UISwitch()
        if indexPath.row == 0 {
          uiSwitch.isOn = true
          uiSwitch.addTarget(self, action: #selector(environmentSwitchChanged(_:)), for: .valueChanged)
        } else {
          uiSwitch.addTarget(self, action: #selector(mocksSwitchChanged(_:)), for: .valueChanged)
        }
        cell.accessoryView = uiSwitch
      } else {
        cell.accessoryView = nil
      }
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
    return indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 1) ? nil : indexPath
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    var viewController: UIViewController?
    
    switch (indexPath.section, indexPath.row) {
    case (0, 2):
      viewController = SetColorsTestViewController()
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
  
  @objc func environmentSwitchChanged(_ sender: UISwitch) {
    TLManager.shared.setEnvironment(sender.isOn ? .staging : .production)
  }
  
  @objc func mocksSwitchChanged(_ sender: UISwitch) {
    TLManager.shared.setIsTestServer(sender.isOn)
  }
  
}
