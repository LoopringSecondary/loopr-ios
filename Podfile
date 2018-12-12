# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

def shared_pods
    # Pods for loopr-ios
    pod 'Charts', '3.2.1'
    pod 'SwiftLint'
    pod 'SwiftTheme'
    pod 'Socket.IO-Client-Swift', '~> 13.1.0'
    pod 'NotificationBannerSwift', '~> 1.6.3'
    pod 'SVProgressHUD'
    pod 'ESTabBarController-swift'
    pod 'SwiftyMarkdown'
    pod 'MKDropdownMenu'
    pod 'StepSlider', git: 'https://github.com/xiaowheat/StepSlider.git'
    
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'lottie-ios'
    pod 'WeChat_SDK', '~> 1.8.1'
    
    # Pods for keystone
    pod 'Geth', '1.8.8'
    pod 'BigInt', '3.0.1'
    pod 'CryptoSwift', '0.8.3'
    pod 'secp256k1_ios', git: 'https://github.com/shamatar/secp256k1_ios.git', inhibit_warnings: true
    pod 'TrezorCrypto', '0.0.9', inhibit_warnings: true
    pod 'SipHash', '1.2.0'
end

target 'loopr-ios' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  shared_pods


  target 'loopr-iosTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'loopr-iosUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
