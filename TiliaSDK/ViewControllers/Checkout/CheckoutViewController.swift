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
  private let builder = CheckoutSectionBuilder()
  private var subscriptions: Set<AnyCancellable> = []
  private var sections: [CheckoutSectionBuilder.Section] = []
  
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
    tableView.register(CheckoutPaymentFooterView.self)
    tableView.register(CheckoutPaymentMethodCell.self)
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
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections[section].numberOfRows
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return sections[indexPath.section].cell(for: tableView, at: indexPath)
  }
  
}

// MARK: - UITableViewDelegate {

extension CheckoutViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return sections[section].header(for: tableView, in: section)
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return sections[section].footer(for: tableView,
                                    in: section,
                                    delegate: self,
                                    textViewDelegate: self)
  }
  
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension CheckoutViewController: UIAdaptivePresentationControllerDelegate {
  
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    completion?(viewModel.successfulPayment.value)
  }
  
}

// MARK: - CheckoutPaymentFooterViewDelegate

extension CheckoutViewController: CheckoutPaymentFooterViewDelegate {
  
  func checkoutPaymentFooterViewFullFilledButtonDidTap(_ footerView: CheckoutPaymentFooterView) {
    
  }
  
  func checkoutPaymentFooterViewRoundedButtonDidTap(_ footerView: CheckoutPaymentFooterView) {
    dismiss()
  }
  
}

// MARK: - TextViewWithLinkDelegate

extension CheckoutViewController: TextViewWithLinkDelegate {
  
  func textViewWithLink(_ textView: TextViewWithLink, didPressOn link: String) {
    router.showWebView(with: link)
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
        isTosSigned ? self.viewModel.proceedCheckout() : self.dismiss()
      }
    }.store(in: &subscriptions)
    viewModel.content.sink { [weak self] in
      guard let self = self, let content = $0 else { return }
      self.sections = [
        self.builder.summarySection(for: content.invoice),
        self.builder.paymentSection(for: content.balance)
      ]
      self.tableView.reloadData()
    }.store(in: &subscriptions)
  }
  
  func dismiss() {
    let isPaid = viewModel.successfulPayment.value
    router.dismiss { self.completion?(isPaid) }
  }
  
}
