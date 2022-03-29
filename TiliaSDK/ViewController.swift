//
//  ViewController.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 20.03.2022.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    let token = "eyJhbGciOiJSUzUxMiIsInR5cCI6IkpXVCJ9.eyJhY2NvdW50X2lkIjoiZThiMjhmYzMtNWJkOC00YTVhLWJhZmYtOTJiMTg4MTMzM2RhIiwiY2xpZW50X2lkIjoiOTE0ZGQ3NTAtZGIxNi00YTIzLThiYjUtZmFkMzBiOGUzYWFhIiwiZXhwIjoxNjQ3OTcyNjIzLCJpYXQiOjE2NDc5NjkwMjMsImludGVncmF0b3IiOiJ0aWxpYS1zZGtzIiwianRpIjoiN2I4N2EwMjEtYjJlOC00MTVlLWEzZjItNmZjMWYxNDc4ZTU2IiwibmJmIjowLCJzY29wZXMiOlsidXNlcl9pbmZvIiwicmVhZF9wYXltZW50X21ldGhvZCIsIndyaXRlX3BheW1lbnRfbWV0aG9kIiwicmVhZF9reWMiLCJ2ZXJpZnlfa3ljIl0sInRva2VuX3R5cGUiOiJwYXNzd29yZCIsInVzZXJuYW1lIjoiamFuZXNtaXRoQGZha2VlbWFpbC5jb20ifQ.Ay4NldzZanVAj9jNvg3Xk9UdbgXcvQi-btTOdDmEsTmpZVTZvbEf3dt1L9gSBv5J7mGVYnTbtaA2mUE_u8E7xEl6I1t5mplLcVlSq49jvM6dtSx4UT43whMp1MVavH9ftkAUy89ZDwQAuq0U4ElmTbND2dGhOXZu6HwjI1lxWHkp396ZYWxLTQuxtz-ODnfISm9lhQyFDVbTi1RA_wA2AvTxkVDUM49D2D1xE4DTu1X2x6-gagG7EQVFiiMI6FbBQfNcXsjpIfq_ROzko0aNSfOYxhFUfxO32aig7ONphmnFKdq18zH5agir1l5jFcorkupsiDA6Xxft8f8cTC-TKQ"
    TLManager.shared.setToken(token)
  }


  @IBAction func doSmth(_ sender: Any) {
    TLManager.shared.presentTosIsRequiredViewController(on: self, animated: true)
//    TLManager.shared.getUserBalanceByCurrencyCode("TST") { result in
//      switch result {
//      case .success(let model):
//        print(model)
//      case .failure(let error):
//        print(error)
//      }
//    }
  }
}

