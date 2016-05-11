# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
use_frameworks!


target 'PositionIn' do
  pod 'KeychainAccess', '~> 2.3.1'
  pod 'HanekeSwift', '~> 0.10'
  pod 'KYDrawerController', '~> 1.1'
  pod 'UIImageEffects', :inhibit_warnings => true
  pod 'XLForm', '~> 3.1.0'
  pod 'ImagePickerSheetController', '~> 0.9'
  pod 'GoogleMaps', '1.11.1'
  pod 'HMSegmentedControl', '~> 1.5.2'
  pod 'JDStatusBarNotification', '~> 1.5'
  pod 'JSQMessagesViewController', '~> 7.2'
  pod 'Google/Analytics'
  pod 'PosInCore', :path => 'PosInCore'
  pod 'RealmSwift', '~> 0.99'
  pod 'Fabric', '~> 1.0'
  pod 'Crashlytics', '~> 3.0'
  pod 'Braintree', '~> 4.1.2'
  pod 'Box', '~> 2.0'
  pod 'NewRelicAgent', '~> 5.3.6'
  pod 'CHCSVParser', '~> 2.1.0'
  pod 'TTTAttributedLabel', '~> 1.13'
  pod 'LNNotificationsUI', :podspec => 'https://raw.githubusercontent.com/rkolchakov/LNNotificationsUI/master/LNNotificationsUI.podspec'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      if ['GoogleMaps'].include?(target.name) | ['RealmSwift'].include?(target.name) | ['Realm'].include?(target.name)
        target.build_configurations.each do |config|
          config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
      end
    end
  end

end


