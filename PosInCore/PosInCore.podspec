Pod::Spec.new do |s|
  s.license = 'MIT'
  s.name = 'PosInCore'
  s.summary  = 'Core reusable funcionality'
  s.authors  = { 'Alexandr Goncharov' => 'ag@bekitzur.com' }
  s.version = '0.0.1'
  s.platform = :ios
  s.ios.deployment_target = '8.0'
  s.source_files =  '*.swift' , 'TableView/*.swift'
  s.dependency 'Alamofire', '~> 1.3.0'
  s.dependency 'ObjectMapper', '0.12'
  s.dependency 'BrightFutures', '~> 2.0.1'
  s.requires_arc = true
  s.ios.deployment_target = "8.0"
end
