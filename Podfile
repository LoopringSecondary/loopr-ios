# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'loopr-ios' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for loopr-ios
  pod 'Charts', '3.0.5'
  pod 'SwiftLint'
  pod 'SwiftTheme'
  pod 'Socket.IO-Client-Swift', '~> 13.1.0'
  pod 'NotificationBannerSwift'
  pod 'SVProgressHUD'
  pod 'ESTabBarController-swift'
  pod 'SwiftyMarkdown'
  pod 'MKDropdownMenu'
  pod 'StepSlider', :git => 'git@github.com:xiaowheat/StepSlider.git'

  pod 'Fabric'
  pod 'Crashlytics'

  # Pods for keystone
  pod 'Geth', '1.8.8'
  pod 'BigInt', '3.0.1'
  pod 'CryptoSwift', '0.8.3'
  pod 'secp256k1_ios', git: 'https://github.com/shamatar/secp256k1_ios.git', inhibit_warnings: true
  pod 'TrezorCrypto', '0.0.4', inhibit_warnings: true
  pod 'SipHash', '1.2.0'

  target 'loopr-iosTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'loopr-iosUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
