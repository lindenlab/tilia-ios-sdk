# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'TiliaSDK' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'Alamofire'
  pod 'lottie-ios'
  pod 'PocketSVG'
  
  target 'TiliaSDKTests' do
    inherit! :search_paths
    pod 'Alamofire'
  end
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
