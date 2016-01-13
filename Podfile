# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
use_frameworks!


target 'PositionIn' do
    pod 'KeychainAccess' , '~> 2.3.1'
    pod 'HanekeSwift', '~> 0.10'
    pod 'KYDrawerController', '~> 1.1'
    pod 'UIImageEffects', :inhibit_warnings => true
    pod 'XLForm', '~> 3.0.2'
    pod 'ImagePickerSheetController', '~> 0.9'
    pod 'GoogleMaps', '~> 1.10'
	pod 'HMSegmentedControl', '~> 1.5.2'
    pod 'JDStatusBarNotification', '~> 1.5'
    pod 'JSQMessagesViewController', '~> 7.2'
    pod 'Google/Analytics'
    pod 'PosInCore', :path => 'PosInCore'
    pod 'RealmSwift', '~> 0.97.0'
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'Braintree', '~> 3.9'
    pod 'FBSDKCoreKit', '~> 4.7'
    pod 'FBSDKLoginKit', '~> 4.7'
    pod 'Box', '~> 2.0'
    
    post_install do |installer|        
        installer.pods_project.targets.each do |target|
            if ['GoogleMaps'].include?(target.name)
                target.build_configurations.each do |config|
                    config.build_settings['ENABLE_BITCODE'] = 'NO'
                end
            end
        end
    end
    
end

target 'PositionInTests' do

end


