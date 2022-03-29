//
//  ViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import UIKit

class DemoViewController: UITableViewController {

  let items: [String] = [
    "Is staging",
    "getTosRequiredForUser",
    "getUserBalanceByCurrency",
    "TOS flow",
  ]
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    if indexPath.row == 0 {
      let uiSwitch = UISwitch()
      uiSwitch.isOn = true
      uiSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
      cell.accessoryView = uiSwitch
    } else {
      cell.accessoryView = nil
    }
    cell.textLabel?.text = items[indexPath.row]
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    guard indexPath.row != 0 else { return }
    
    var viewController: UIViewController?
    
    switch indexPath.row {
    case 1:
      viewController = TosRequiredForUserTestViewController()
    case 2:
      viewController = UserBalanceByCurrencyTestViewController()
    case 3:
      viewController = TosRequiredForUserFlowTestViewController()
    default:
      break
    }
    
    viewController?.title = items[indexPath.row]
    navigationController?.pushViewController(viewController!, animated: true)
  }
  
  @objc func switchChanged(_ sender: UISwitch) {
    TLManager.shared.setEnvironment(sender.isOn ? .staging : .production)
  }
  
}

