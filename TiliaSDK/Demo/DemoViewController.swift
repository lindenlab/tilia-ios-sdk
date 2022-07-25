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
    Section(name: "Configurable section", items: ["Is staging",
                                                  "Use Mocks (only for UI Tests)",
                                                  "Set colors"]),
    Section(name: "Testable section", items: ["getTosRequiredForUser",
                                              "getUserBalanceByCurrency",
                                              "TOS flow",
                                              "Checkout flow",
                                              "KYC flow"])
  ]
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections[section].items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    let section = indexPath.section
    let row = indexPath.row
    if section == 0 && (row == 0 || row == 1) {
      let uiSwitch = UISwitch()
      if row == 0 {
        uiSwitch.isOn = true
        uiSwitch.accessibilityIdentifier = nil
      } else {
        uiSwitch.isOn = false
        uiSwitch.accessibilityIdentifier = "useMocksSwitch"
      }
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
    let row = indexPath.row
    return indexPath.section == 0 && (row == 0 || row == 1) ? nil : indexPath
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
    case (1, 4):
      viewController = KycFlowTestViewController()
    default:
      break
    }
    
    guard let viewController = viewController else { return }
    viewController.title = sections[indexPath.section].items[indexPath.row]
    navigationController?.pushViewController(viewController, animated: true)
  }
  
  @objc func switchChanged(_ sender: UISwitch) {
    if sender.accessibilityIdentifier == "useMocksSwitch" {
      TLManager.shared.setIsTestServer(sender.isOn)
    } else {
      TLManager.shared.setEnvironment(sender.isOn ? .staging : .production)
    }
  }
  
}

