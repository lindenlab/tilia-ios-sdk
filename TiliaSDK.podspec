Pod::Spec.new do |s|
  s.name = 'TiliaSDK'
  s.version = '0.1.0'
  s.summary = 'The Tilia SDK'
  s.homepage = 'https://github.com/lindenlab/tilia-ios-sdk'
  s.author = { 'Tilia' }
  s.source = { :git => 'https://github.com/lindenlab/tilia-ios-sdk.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.source_files = 'TiliaSDK/**/*'
  s.resource_bundle = { 'TiliaSDK': 'TiliaSDK/Resources/**/*' }
  s.dependency 'Alamofire'
end