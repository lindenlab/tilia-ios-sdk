//
//  VerifyEmailViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 15.05.2023.
//

import UIKit
import Combine

final class VerifyEmailViewController: BaseViewController {
  
  override var hideableView: UIView {
    return stackView
  }
  
  private let viewModel: VerifyEmailViewModelProtocol
  private let router: VerifyEmailRoutingProtocol
  private var subscriptions: Set<AnyCancellable> = []
  
  private let imageView: UIImageView = {
    let imageView = UIImageView(image: .paperPlaneIcon?.withRenderingMode(.alwaysTemplate))
    imageView.tintColor = .primaryColor
    imageView.contentMode = .center
    return imageView
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = .boldSystemFont(ofSize: 20)
    label.textColor = .primaryTextColor
    label.textAlignment = .center
    label.text = viewModel.mode.title
    return label
  }()
  
  private lazy var messageLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.font = .systemFont(ofSize: 16)
    label.textColor = .primaryTextColor
    label.text = viewModel.mode.message(for: viewModel.email)
    return label
  }()
  
  private lazy var textField: RoundedTextField = {
    let textField = RoundedTextField()
    textField.placeholder = L.enterSixDigitCode
    textField.returnKeyType = .done
    textField.isReturnKeyEnabled = false
    textField.keyboardType = .numberPad
    textField.delegate = self
    return textField
  }()
  
  private lazy var cancelButton: NonPrimaryButton = {
    let button = NonPrimaryButton()
    button.setTitle(L.cancel, for: .normal)
    button.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
    return button
  }()
  
  private lazy var textView: TextViewWithLink = {
    let textView = TextViewWithLink()
    let text = L.clickToResendMessage
    let links = [L.clickToResendTitle]
    textView.textData = (text, links)
    textView.font = .systemFont(ofSize: 16)
    textView.textColor = .primaryTextColor
    textView.shouldUnderlineLink = false
    textView.linkDelegate = self
    return textView
  }()
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [imageView,
                                                   titleLabel,
                                                   messageLabel,
                                                   textField,
                                                   cancelButton,
                                                   textView])
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.setCustomSpacing(24, after: imageView)
    stackView.setCustomSpacing(32, after: titleLabel)
    stackView.setCustomSpacing(24, after: textField)
    return stackView
  }()
  
  init(email: String,
       flow: TLEvent.Flow,
       mode: VerifyEmailMode,
       manager: NetworkManager,
       onEmailVerified: @escaping (VerifyEmailMode) -> Void,
       onError: ((TLErrorCallback) -> Void)?) {
    let viewModel = VerifyEmailViewModel(email: email,
                                         flow: flow,
                                         mode: mode,
                                         manager: manager,
                                         onEmailVerified: onEmailVerified,
                                         onError: onError)
    let router = VerifyEmailRouter()
    self.viewModel = viewModel
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
    viewModel.sendCode()
  }
  
}


// MARK: - UITextFieldDelegate

extension VerifyEmailViewController: UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard !string.isEmpty else { return true }
    guard !string.trimmingCharacters(in: CharacterSet.decimalDigits.inverted).isEmpty else { return false }
    let newText = textField.text?.newString(forRange: range, withReplacementString: string) ?? ""
    if newText.count == 6 {
      textField.resignFirstResponder()
      viewModel.verifyCode(newText)
    }
    return newText.count <= 6
  }
  
}

// MARK: - TextViewWithLinkDelegate

extension VerifyEmailViewController: TextViewWithLinkDelegate {
  
  func textViewWithLink(_ textView: TextViewWithLink, didPressOn link: String) {
    textField.resignFirstResponder()
    viewModel.sendCode()
  }
  
}

// MARK: - Private Methods

private extension VerifyEmailViewController {
  
  func setup() {
    view.addClosingKeyboardOnTap()
    view.addSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
      stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16)
    ])
  }
  
  func bind() {
    viewModel.loading.sink { [weak self] in
      guard let self = self else { return }
      $0 ? self.startLoading() : self.stopLoading()
    }.store(in: &subscriptions)
    
    viewModel.error.sink { [weak self] in
      guard let self = self else { return }
      if $0.value {
        self.showCancelButton()
      }
      self.router.showToast(title: L.errorVerifyEmailTitle,
                            message: L.errorVerifyEmailMessage)
    }.store(in: &subscriptions)
    
    viewModel.emailVerified.sink { [weak self] in
      guard let self = self else { return }
      self.router.dismiss { self.viewModel.complete() }
    }.store(in: &subscriptions)
  }
  
  @objc func cancelButtonDidTap() {
    router.dismiss()
  }
  
  func showCancelButton() {
    showCloseButton(target: self, action: #selector(cancelButtonDidTap))
  }
  
}
