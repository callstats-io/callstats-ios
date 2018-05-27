platform :ios, '9.0'
use_frameworks!

target 'demo' do
  pod 'Socket.IO-Client-Swift'
  pod 'GoogleWebRTC'

  post_install do |installer|
    installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
      configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
      configuration.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
