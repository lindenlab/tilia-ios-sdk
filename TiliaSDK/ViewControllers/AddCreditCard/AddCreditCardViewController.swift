//
//  AddCreditCardViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 21.04.2022.
//

import UIKit
import Combine

final class AddCreditCardViewController: BaseViewController, LoadableProtocol {
  
  var hideableView: UIView { return stackView }
  var spinnerPosition: CGPoint { return stackView.center }

  private let viewModel: AddCreditCardViewModelProtocol
  private let router: AddCreditCardRoutingProtocol
  private var subscriptions: Set<AnyCancellable> = []
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .primaryTextColor
    label.text = L.addCreditCardTitle
    label.font = UIFont.boldSystemFont(ofSize: 20)
    return label
  }()
  
  private let subTitleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .primaryTextColor
    label.text = L.addCreditCardMessage
    label.font = UIFont.systemFont(ofSize: 16)
    label.numberOfLines = 0
    return label
  }()
  
  private lazy var openButton: PrimaryButton = {
    let button = PrimaryButton()
    button.setTitle(L.openBrowser, for: .normal)
    button.addTarget(self, action: #selector(openButtonDidTap), for: .touchUpInside)
    button.accessibilityIdentifier = "openButton"
    return button
  }()
  
  private lazy var goBackButton: NonPrimaryButton = {
    let button = NonPrimaryButton()
    button.setTitle(L.goBack, for: .normal)
    button.addTarget(self, action: #selector(goBackButtonDidTap), for: .touchUpInside)
    button.accessibilityIdentifier = "goBackButton"
    return button
  }()
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [titleLabel,
                                                   subTitleLabel,
                                                   openButton,
                                                   goBackButton])
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.setCustomSpacing(32, after: subTitleLabel)
    return stackView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
  }
  
  init(manager: NetworkManager) {
    let router = AddCreditCardRouter()
    self.viewModel = AddCreditCardViewModel(manager: manager)
    self.router = router
    super.init(nibName: nil, bundle: nil)
    router.viewController = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Private Methods

private extension AddCreditCardViewController {
  
  func setup() {
    view.addSubview(stackView)
    
    NSLayoutConstraint.activate([
      stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16)
    ])
  }
  
  func bind() {
    viewModel.loading.sink { [weak self] in
      guard let self = self else { return }
      $0 ? self.startLoading() : self.stopLoading()
    }.store(in: &subscriptions)
    
    viewModel.error.sink { [weak self] _ in
      self?.router.showToast(title: L.errorAddCreditTitle,
                             message: L.errorAddCreditMessage)
    }.store(in: &subscriptions)
    
    viewModel.openUrl.sink { [weak self] in
      self?.router.showWebView(with: $0)
    }.store(in: &subscriptions)
  }
  
  @objc func openButtonDidTap() {
    viewModel.openBrowser()
  }
  
  @objc func goBackButtonDidTap() {
    router.dismiss()
  }
  
}
