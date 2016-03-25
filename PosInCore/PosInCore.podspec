Pod::Spec.new do |s|
  s.license = 'MIT'
  s.name = 'PosInCore'
  s.summary  = 'Core reusable funcionality'
  s.authors  = { 'Alexandr Goncharov' => 'ag@bekitzur.com' }
  s.version = '0.0.1'
  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.source_files =  '*.swift' , 'TableView/*.swift'
  s.dependency 'Alamofire', '~> 3.2.1'
  s.dependency 'ObjectMapper', '~>  1.1.5'
  s.dependency 'BrightFutures', '~> 3.0'
  s.requires_arc = true
  s.homepage='http://positionin.com'
  s.source={ :git => 'https://github.com/solunalabs/position-in-ios.git'}
end
