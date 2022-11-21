//
//  SendReceiptViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 19.08.2022.
//

import UIKit
import Combine

final class SendReceiptViewController: BaseViewController {
  
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
  
  private lazy var dismissButton: NonPrimaryButton = {
    let button = NonPrimaryButton()
    button.setImage(.closeIcon?.withRenderingMode(.alwaysTemplate),
                    for: .normal)
    button.imageView?.tintColor = .primaryTextColor
    button.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
    return button
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
  
  private lazy var sendButton: PrimaryButton = {
    let button = PrimaryButton(style: .titleAndImageCenter)
    button.setImage(.sendIcon, for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(sendButtonDidTap), for: .touchUpInside)
    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    button.setTitle(L.send, for: .normal)
    button.setTitleForLoadingState(L.sending)
    button.isEnabled = false
    button.accessibilityIdentifier = "sendButton"
    return button
  }()
  
  init(transactionId: String,
       manager: NetworkManager,
       onEmailSent: @escaping () -> Void,
       onError: ((TLErrorCallback) -> Void)?) {
    let viewModel = SendReceiptViewModel(transactionId: transactionId,
                                         manager: manager,
                                         onEmailSent: onEmailSent,
                                         onError: onError)
    let router = SendReceiptRouter()
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
    textField.resignFirstResponder()
    sendEmail()
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
    
    let stackView = UIStackView(arrangedSubviews: [headerStackView, textField])
    stackView.axis = .vertical
    stackView.spacing = 16
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(stackView)
    view.addSubview(sendButton)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16),
      stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
      stackView.bottomAnchor.constraint(equalTo: sendButton.topAnchor, constant: -16),
      sendButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
      dismissButton.heightAnchor.constraint(equalToConstant: 30),
      dismissButton.widthAnchor.constraint(equalToConstant: 30)
    ])
  }
  
  func bind() {
    viewModel.loading.sink { [weak self] in
      guard let self = self else { return }
      self.textField.isUserInteractionEnabled = !$0
      self.sendButton.isLoading = $0
    }.store(in: &subscriptions)
    
    viewModel.error.sink { [weak self] _ in
      self?.router.showToast(title: L.errorSendReceiptTitle,
                             message: L.errorSendReceiptMessage)
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
  }
  
  @objc func closeButtonDidTap() {
    router.dismiss()
  }
  
  @objc func sendButtonDidTap() {
    textField.resignFirstResponder()
    sendEmail()
  }
  
  func sendEmail() {
    viewModel.sendEmail(textField.text ?? "")
  }
  
}
