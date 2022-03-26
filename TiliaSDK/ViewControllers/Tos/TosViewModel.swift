//
//  TosViewModel.swift
//  TiliaSDK
//
//  Created by Serhii.Petrishenko on 23.03.2022.
//

import Combine

protocol TosViewModelInputProtocol { }

protocol TosViewModelOutputProtocol { }

protocol TosViewModelProtocol: TosViewModelInputProtocol, TosViewModelOutputProtocol { }

final class TosViewModel: TosViewModelProtocol {
  
  @Published var title = ""
  
}
