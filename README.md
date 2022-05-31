# Tilia iOS SDK

This is a repository for a Tilia iOS SDK. It includes demo app that shows all possibilities and flows.

## Installation

Using [CocoaPods](https://cocoapods.org), add the following to your Podfile:

```
pod 'TiliaSDK'
```

## Usage

To interact with Tilia SDK use TLManager. SDK supports customization for environment, timeout iterval for requests, colors for dark/light theme.

## Configuration

### Set token
```swift
TLManager.shared.setToken("USER_PASSWORD_TOKEN")
```

### Set timeout interval, in seconds
```swift
TLManager.shared.setTimeoutInterval(10)
```

### Set environment
```swift
TLManager.shared.setEnvironment(.production)
```

### Theme customization
```swift
TLManager.shared.setBackgroundColor(forLightMode: UIColor(), andDarkMode: UIColor())
TLManager.shared.setPrimaryColor(forLightMode: UIColor(), andDarkMode: UIColor())
TLManager.shared.setSuccessBackgroundColor(forLightMode: UIColor(), andDarkMode: UIColor())
TLManager.shared.setFailureBackgroundColor(forLightMode: UIColor(), andDarkMode: UIColor())
```

## Flows

### Terms of Service
```swift
let yourViewControllerForPresenting = UIViewController()
TLManager.shared.setToken("USER_PASSWORD_TOKEN")
TLManager.shared.presentTosIsRequiredViewController(on: yourViewControllerForPresenting,
                                                    animated: true,
                                                    onComplete: { onComplete in print(onComplete.description) },
                                                    onError: { onError in print(onError.description) })
```

### Checkout
```swift
let yourViewControllerForPresenting = UIViewController()
TLManager.shared.setToken("AUTHORIZED_USER_PASSWORD_TOKEN")
TLManager.shared.presentCheckoutViewController(on: yourViewControllerForPresenting,
                                               withInvoiceId: "AUTHORIZED_INVOICE_ID",
                                               animated: true,
                                               onUpdate: { onUpdate in print(onUpdate.description) },
                                               onComplete: { onComplete in print(onComplete.description) },
                                               onError: { onError in print(onError.description) })
```

## Helper methods

### getTosRequiredForUser
```swift
TLManager.shared.setToken("USER_PASSWORD_TOKEN")
TLManager.shared.getTosRequiredForUser { result in
  print(result)
}
```

### getUserBalanceByCurrencyCode
```swift
TLManager.shared.setToken("USER_PASSWORD_TOKEN")
TLManager.shared.getUserBalanceByCurrencyCode("USD") { result in
  print(result)
}
```
