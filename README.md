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
```
TLManager.shared.setToken("USER_PASSWORD_TOKEN")
```

### Set timeout interval, in seconds
```
TLManager.shared.setTimeoutInterval(10)
```

### Set environment
```
TLManager.shared.setEnvironment(.production)
```

### Theme customization
```
TLManager.shared.setBackgroundColor(forLightMode: UIColor(), andDarkMode: UIColor())
TLManager.shared.setPrimaryColor(forLightMode: UIColor(), andDarkMode: UIColor())
TLManager.shared.setSuccessBackgroundColor(forLightMode: UIColor(), andDarkMode: UIColor())
TLManager.shared.setFailureBackgroundColor(forLightMode: UIColor(), andDarkMode: UIColor())
```

## Flows

### Terms of Service
```
let yourViewControllerForPresenting = UIViewController()
TLManager.shared.setToken("USER_PASSWORD_TOKEN")
TLManager.shared.presentTosIsRequiredViewController(on: yourViewControllerForPresenting,
                                                    animated: true,
                                                    onComplete: { onComplete in print(onComplete.description) },
                                                    onError: { onError in print(onError.description) })
```

### Checkout
```
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
```
TLManager.shared.setToken("USER_PASSWORD_TOKEN")
TLManager.shared.getTosRequiredForUser { result in
  print(result)
}
```

### getUserBalanceByCurrencyCode
```
TLManager.shared.setToken("USER_PASSWORD_TOKEN")
TLManager.shared.getUserBalanceByCurrencyCode("USD") { result in
  print(result)
}
```
