//
//  SendReceiptViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 19.08.2022.
//

import UIKit
import Combine

final class SendReceiptViewController: BaseViewController {
  
  override var hideableView: UIView {
    return stackView
  }
  
  private let viewModel: SendReceiptViewModelProtocol
  private let router: SendReceiptRoutingProtocol
  private var subscriptions: Set<AnyCancellable> = []
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = L.emailReceipt
    label.numberOfLines = 0
    label.font = .boldSystemFont(ofSize: 20)
    label.textColor = .primaryTextColor
    return label
  }()
  
  private lazy var dismissButton: CloseButton = {
    let button = CloseButton()
    button.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
    return button
  }()
  
  private let messageLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 16)
    label.textColor = .primaryTextColor
    label.numberOfLines = 0
    return label
  }()
  
  private lazy var textField: RoundedTextField = {
    let textField = RoundedTextField()
    textField.keyboardType = .emailAddress
    textField.returnKeyType = .send
    textField.delegate = self
    textField.enablesReturnKeyAutomatically = true
    textField.accessibilityIdentifier = "emailTextField"
    let attachment = NSTextAttachment(data: nil, ofType: nil)
    attachment.image = .envelopeIcon?.withRenderingMode(.alwaysTemplate).withTintColor(.borderColor)
    let attachmentAttributedString = NSAttributedString(attachment: attachment)
    let attributedString = NSMutableAttributedString(attributedString: attachmentAttributedString)
    let placeholderAttributedString = " \(L.emailPlaceholder)"
    let attributes: [NSAttributedString.Key : Any] = [
      .foregroundColor: UIColor.borderColor,
      .font: UIFont.systemFont(ofSize: 16)
    ]
    attributedString.append(.init(string: placeholderAttributedString, attributes: attributes))
    textField.attributedPlaceholder = attributedString
    return textField
  }()
  
  private lazy var cancelEditingButton: NonPrimaryButton = {
    let button = NonPrimaryButton()
    button.setTitle(L.cancel, for: .normal)
    button.addTarget(self, action: #selector(cancelEditingButtonDidTap), for: .touchUpInside)
    return button
  }()
  
  private lazy var sendButton: PrimaryButton = {
    let button = PrimaryButton()
    button.addTarget(self, action: #selector(sendButtonDidTap), for: .touchUpInside)
    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    button.isEnabled = false
    button.accessibilityIdentifier = "sendButton"
    return button
  }()
  
  private lazy var buttonsStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [cancelEditingButton, sendButton])
    stackView.spacing = 8
    return stackView
  }()
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [messageLabel, textField, buttonsStackView])
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  init(transactionId: String,
       manager: NetworkManager,
       onEmailSent: @escaping () -> Void,
       onUpdate: ((TLUpdateCallback) -> Void)?,
       onError: ((TLErrorCallback) -> Void)?) {
    let viewModel = SendReceiptViewModel(transactionId: transactionId,
                                         manager: manager,
                                         onEmailSent: onEmailSent,
                                         onUpdate: onUpdate,
                                         onError: onError)
    let router = SendReceiptRouter(dataStore: viewModel)
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
    viewModel.load()
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    view.endEditing(true)
  }
  
}

// MARK: - UITextFieldDelegate

extension SendReceiptViewController: UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let newText = textField.text?.newString(forRange: range, withReplacementString: string) ?? ""
    viewModel.checkEmail(newText)
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    sendButtonDidTap()
    return true
  }
  
}

// MARK: - Private Methods

private extension SendReceiptViewController {
  
  func setup() {
    let headerStackView = UIStackView(arrangedSubviews: [titleLabel, dismissButton])
    headerStackView.alignment = .center
    headerStackView.distribution = .equalCentering
    headerStackView.spacing = 4
    headerStackView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(headerStackView)
    view.addSubview(stackView)
    
    NSLayoutConstraint.activate([
      headerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      headerStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
      headerStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
      headerStackView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -16),
      stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16)
    ])
  }
  
  func bind() {
    viewModel.loading.sink { [weak self] in
      guard let self = self else { return }
      $0 ? self.startLoading() : self.stopLoading()
    }.store(in: &subscriptions)
    
    viewModel.sending.sink { [weak self] in
      guard let self = self else { return }
      self.textField.isUserInteractionEnabled = !$0
      self.sendButton.isLoading = $0
    }.store(in: &subscriptions)
    
    viewModel.error.sink { [weak self] in
      guard let self = self else { return }
      if $0.value {
        self.showCancelButton()
      }
      self.router.showToast(title: L.errorSendReceiptTitle,
                            message: L.errorSendReceiptMessage)
    }.store(in: &subscriptions)
    
    viewModel.defaultEmail.sink { [weak self] in
      self?.textField.text = $0
    }.store(in: &subscriptions)
    
    viewModel.emailSent.sink { [weak self] in
      guard let self = self else { return }
      self.router.dismiss { self.viewModel.complete() }
    }.store(in: &subscriptions)
    
    viewModel.isEmailValid.sink { [weak self] in
      guard let self = self else { return }
      self.sendButton.isEnabled = $0
      self.textField.isReturnKeyEnabled = $0
    }.store(in: &subscriptions)
    
    viewModel.emailVerificationMode.sink { [weak self] in
      guard let self = self else { return }
      self.messageLabel.text = $0.message
      self.cancelEditingButton.isHidden = $0.isCancelEditingButtonHidden
      self.sendButton.setTitle($0.sendButtonTitle, for: .normal)
      self.buttonsStackView.axis = $0.stackViewAxis
      self.buttonsStackView.alignment = $0.stackViewAlignment
      self.buttonsStackView.distribution = $0.stackViewDistribution
      self.textField.rightView = self.editButton(isHidden: $0.isEditButtonHidden)
      self.textField.rightViewMode = $0.isEditButtonHidden ? .never : .always
      self.textField.isUserInteractionEnabled = $0.isTextFieldEditable
    }.store(in: &subscriptions)
    
    viewModel.verifyEmail.sink { [weak self] in
      self?.router.routeToVerifyEmailView()
    }.store(in: &subscriptions)
    
    viewModel.emailVerified.sink { [weak self] in
      self?.router.showToast(title: L.success,
                             message: $0,
                             isSuccess: true)
    }.store(in: &subscriptions)
  }
  
  @objc func closeButtonDidTap() {
    router.dismiss()
  }
  
  @objc func cancelEditingButtonDidTap() {
    viewModel.cancelEditEmail(textField.text ?? "")
    textField.resignFirstResponder()
  }
  
  @objc func sendButtonDidTap() {
    textField.resignFirstResponder()
    viewModel.sendEmail(textField.text ?? "")
  }
  
  @objc func editButtonDidTap() {
    viewModel.editEmail()
    textField.becomeFirstResponder()
  }
  
  func showCancelButton() {
    showCloseButton(target: self, action: #selector(closeButtonDidTap))
  }
  
  func editButton(isHidden: Bool) -> UIButton? {
    guard !isHidden else { return nil }
    let button = EditButton()
    button.accessibilityIdentifier = "editButton"
    button.addTarget(self,
                     action: #selector(editButtonDidTap),
                     for: .touchUpInside)
    return button
  }
  
}

// MARK: - Private Helpers

private extension EmailVerificationModeModel {
  
  var message: String {
    switch self {
    case .notVerified: return L.emailIsNotVerifiedForUpdatesMessage
    case .verified, .edit: return L.emailIsVerifiedForUpdatesMessage
    }
  }
  
  var isCancelEditingButtonHidden: Bool {
    switch self {
    case .notVerified, .verified: return true
    case .edit: return false
    }
  }
  
  var sendButtonTitle: String {
    switch self {
    case .notVerified: return L.verifyEmail
    case .verified: return L.sendToThisEmail
    case .edit: return L.updateEmail
    }
  }
  
  var stackViewAxis: NSLayoutConstraint.Axis {
    switch self {
    case .notVerified, .verified: return .vertical
    case .edit: return .horizontal
    }
  }
  
  var stackViewAlignment: UIStackView.Alignment {
    switch self {
    case .notVerified, .verified: return .trailing
    case .edit: return .fill
    }
  }
  
  var stackViewDistribution: UIStackView.Distribution {
    switch self {
    case .notVerified, .verified: return .fill
    case .edit: return .fillEqually
    }
  }
  
}
