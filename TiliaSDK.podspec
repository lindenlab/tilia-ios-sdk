Pod::Spec.new do |s|
  s.name = 'TiliaSDK'
  s.version = '2.0.0'
  s.summary = 'The Tilia SDK'
  s.homepage = 'https://github.com/lindenlab/tilia-ios-sdk'
  s.author = 'Tilia'
  s.source = { git: 'https://github.com/lindenlab/tilia-ios-sdk.git', tag: s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.source_files = 'TiliaSDK/ViewControllers/**/*.swift', 'TiliaSDK/Extensions/*.swift', 'TiliaSDK/Managers/*.swift', 'TiliaSDK/Routers/*.swift', 'TiliaSDK/Models/*.swift'
  s.resource_bundle = { 'TiliaSDK': 'TiliaSDK/Resources/**/*' }
  s.dependency 'Alamofire'
  s.swift_versions = ['5.3', '5.4', '5.5']
end