//
//  BaseTableViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 19.08.2022.
//

import UIKit

class BaseTableViewController: BaseViewController {
  
  let tableView: UITableView
  
  init(style: UITableView.Style = .grouped) {
    tableView = UITableView(frame: .zero, style: style)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setup()
  }
  
}

// MARK: - UITableViewDataSource

extension BaseTableViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
  
}

// MARK: - UITableViewDelegate

extension BaseTableViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) { }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return tableView.sectionHeaderHeight
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return tableView.sectionFooterHeight
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return nil
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return nil
  }
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    return nil
  }
  
}

// MARK: - Private Methods

private extension BaseTableViewController {
  
  func setup() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.showsVerticalScrollIndicator = false
    tableView.backgroundColor = .backgroundColor
    tableView.separatorStyle = .none
    tableView.delaysContentTouches = false
    tableView.dataSource = self
    tableView.delegate = self
    view.addSubview(tableView)
    
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
      tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
      tableView.bottomAnchor.constraint(equalTo: divider.topAnchor),
    ])
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: UIResponder.keyboardDidShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  @objc func keyboardWasShown(_ notificiation: NSNotification) {
    guard
      let value = notificiation.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
      let firstResponder = self.view.firstResponder else { return }
    let bottomInset = self.view.frame.height - divider.frame.midY
    tableView.contentInset.bottom = value.cgRectValue.height - bottomInset
    let rect = firstResponder.convert(firstResponder.frame, to: self.tableView)
    tableView.scrollRectToVisible(rect, animated: true)
  }
  
  @objc func keyboardWillBeHidden() {
    tableView.contentInset.bottom = 0
  }
  
}
