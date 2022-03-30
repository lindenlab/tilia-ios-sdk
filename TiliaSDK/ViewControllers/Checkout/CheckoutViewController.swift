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
    tableView.backgroundColor = .clear
    return tableView
  }()
  
  private let logoImageView: UIImageView = {
    let imageView = UIImageView(image: .logoImage)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
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

// MARK: - UIAdaptivePresentationControllerDelegate

extension CheckoutViewController: UIAdaptivePresentationControllerDelegate {
  
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    completion?(false)
  }
  
}

private extension CheckoutViewController {
  
  func setup() {
    view.backgroundColor = .white
    view.addSubview(logoImageView)
    view.addSubview(tableView)
    
    NSLayoutConstraint.activate([
      logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      logoImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
      tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
      tableView.bottomAnchor.constraint(equalTo: logoImageView.topAnchor)
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
          self.router.dismiss {
            self.completion?(false)
          }
        }
      }
    }.store(in: &subscriptions)
  }
  
}
