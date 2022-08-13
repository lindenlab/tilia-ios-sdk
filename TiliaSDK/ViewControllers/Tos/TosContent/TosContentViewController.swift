//
//  TosContentViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 12.08.2022.
//

import UIKit
import Combine

final class TosContentViewController: BaseViewController {
  
  override var hideableView: UIView {
    return textView
  }
  
  private let viewModel: TosContentViewModelProtocol
  private let router: TosContentRoutingProtocol
  private var subscriptions: Set<AnyCancellable> = []
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.text = L.tiliaTos
    label.numberOfLines = 0
    label.font = .boldSystemFont(ofSize: 20)
    label.textColor = .primaryTextColor
    return label
  }()
  
  private lazy var dismissButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(.closeMediumIcon?.withRenderingMode(.alwaysTemplate),
                    for: .normal)
    button.imageView?.tintColor = .primaryButtonTextColor
    button.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
    return button
  }()
  
  private let textView: UITextView = {
    let textView = UITextView()
    textView.textColor = .primaryTextColor
    textView.backgroundColor = .clear
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.font = .systemFont(ofSize: 16)
    textView.isEditable = false
    textView.showsVerticalScrollIndicator = false
    textView.textContainerInset = .zero
    textView.textContainer.lineFragmentPadding = 0
    textView.backgroundColor = .backgroundColor
    return textView
  }()
  
  init(manager: NetworkManager,
       onError: ((TLErrorCallback) -> Void)?) {
    let router = TosContentRouter()
    self.viewModel = TosContentViewModel(manager: manager,
                                         onError: onError)
    self.router = router
    super.init(nibName: nil, bundle: nil)
    router.viewController = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
    viewModel.loadContent()
  }
  
}

// MARK: - Private Methods

private extension TosContentViewController {
  
  func setup() {
    let stackView = UIStackView(arrangedSubviews: [titleLabel, dismissButton])
    stackView.alignment = .top
    stackView.distribution = .equalCentering
    stackView.spacing = 4
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(stackView)
    view.addSubview(textView)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
      stackView.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: -8),
      textView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
      textView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
      textView.bottomAnchor.constraint(equalTo: divider.topAnchor)
    ])
  }
  
  func bind() {
    viewModel.loading.sink { [weak self] in
      guard let self = self else { return }
      $0 ? self.startLoading() : self.stopLoading()
    }.store(in: &subscriptions)
    
    viewModel.content.sink { [weak self] in
      self?.textView.text = $0
    }.store(in: &subscriptions)
    
    viewModel.error.sink { [weak self] _ in
      guard let self = self else { return }
      self.showCancelButton()
      self.router.showToast(title: L.errorTosContentTitle,
                            message: L.errorTosContentMessage)
    }.store(in: &subscriptions)
  }
  
  func showCancelButton() {
    closeButton.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
  }
  
  @objc func closeButtonDidTap() {
    router.dismiss()
  }
  
}
