# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
use_frameworks!


target 'PositionIn' do
    pod 'KeychainAccess'
    pod 'HanekeSwift'
    pod 'KYDrawerController'
    
    target 'PosInCore', :exclusive => true do
        pod 'Alamofire', '~> 1.2.3'
        pod 'ObjectMapper', '0.12'
        pod 'BrightFutures', '~> 2.0.1'
    end
    
    target 'Messaging',  :exclusive => true do
        pod 'Magnet-XMPPFramework', '~> 3.6.9'
    end

end

target 'PositionInTests' do

end


