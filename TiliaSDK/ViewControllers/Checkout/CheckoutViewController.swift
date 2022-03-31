//
//  CheckoutViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 30.03.2022.
//

import UIKit
import Combine

final class CheckoutViewController: UIViewController, LoadableProtocol {
  
  var hideableView: UIView { return tableView }
  var spinnerPosition: CGPoint { return view.center }
  
  private let viewModel: CheckoutViewModelProtocol
  private let router: CheckoutRoutingProtocol
  private let completion: ((Bool) -> Void)?
  private var subscriptions: Set<AnyCancellable> = []
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.showsVerticalScrollIndicator = false
    tableView.backgroundColor = .clear
    tableView.separatorStyle = .none
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(ChekoutTitleHeaderView.self)
    tableView.register(CheckoutPayloadSummaryFooterView.self)
    tableView.register(CheckoutPayloadCell.self)
    tableView.register(CheckoutPayloadActionsFooterView.self)
    return tableView
  }()
  
  private let logoImageView: UIImageView = {
    let imageView = UIImageView(image: .logoImage)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private let divider: DividerView = {
    let divider = DividerView()
    divider.translatesAutoresizingMaskIntoConstraints = false
    return divider
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
    viewModel.checkIsTosRequired()
  }
  
  init(invoiceId: String, completion: ((Bool) -> Void)?) {
    let router = CheckoutRouter()
    self.viewModel = CheckoutViewModel(invoiceId: invoiceId)
    self.router = router
    self.completion = completion
    super.init(nibName: nil, bundle: nil)
    router.viewController = self
    self.presentationController?.delegate = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - UITableViewDataSource

extension CheckoutViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeue(CheckoutPayloadCell.self, for: indexPath)
    cell.configure(description: "description", product: "product", amount: "amount", isDividerHidden: false)
    return cell
  }
  
}

// MARK: - UITableViewDelegate {

extension CheckoutViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = tableView.dequeue(ChekoutTitleHeaderView.self)
    view.configure(title: L.choosePaymentMethod, subTitle: "subTitle")
    return view
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    switch section {
    case 0:
      let view = tableView.dequeue(CheckoutPayloadSummaryFooterView.self)
      view.configure(title: "title", amount: "fsfs")
      return view
    default:
      let view = tableView.dequeue(CheckoutPayloadActionsFooterView.self)
      view.configure(roundedButtonTitle: "Cancel", isTextViewHidden: false, delegate: nil, textViewDelegate: nil)
      return view
    }
  }
  
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension CheckoutViewController: UIAdaptivePresentationControllerDelegate {
  
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    completion?(false)
  }
  
}

// MARK: - Private Methods

private extension CheckoutViewController {
  
  func setup() {
    view.backgroundColor = .white
    view.addSubview(logoImageView)
    view.addSubview(tableView)
    view.addSubview(divider)
    
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
      tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
      tableView.bottomAnchor.constraint(equalTo: divider.topAnchor),
      divider.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
      divider.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
      divider.bottomAnchor.constraint(equalTo: logoImageView.topAnchor, constant: -16),
      logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      logoImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
    ])
  }
  
  func bind() {
    viewModel.loading.sink { [weak self] in
      guard let self = self else { return }
      $0 ? self.startLoading() : self.stopLoading()
    }.store(in: &subscriptions)
    viewModel.error.sink { [weak self] in
      self?.router.showAlert(title: $0.localizedDescription)
    }.store(in: &subscriptions)
    viewModel.needToAcceptTos.sink { [weak self] _ in
      guard let self = self else { return }
      self.router.routeToTosView { isTosSigned in
        if isTosSigned {
          self.viewModel.proceedCheckout()
        } else {
          self.router.dismiss { self.completion?(false) }
        }
      }
    }.store(in: &subscriptions)
  }
  
}
