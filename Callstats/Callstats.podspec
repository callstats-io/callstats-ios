Pod::Spec.new do |spec|
  spec.name = 'Callstats'
  spec.version = '0.1.0'
  spec.platform = :ios, '9.0'
  spec.license = { :type => 'Apache 2.0' }
  spec.authors = { 'Amornchai Kanokpullwad' => 'zoon@callstats.io' }
  spec.homepage = 'https://www.callstats.io'
  spec.summary = 'Callstats WebRTC Analytic Library'
  spec.source = { :git => 'https://github.com/callstats-io/callstats-ios-demoapp.git',
                  :tag => spec.version.to_s }
  spec.source_files = '**/*.{swift}'
  spec.dependency 'GoogleWebRTC', '~> 1.0'
end
