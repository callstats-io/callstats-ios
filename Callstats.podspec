Pod::Spec.new do |s|

  s.name         = "Callstats"
  s.version      = "0.1.0"
  s.summary      = "WebRTC Analytics library for iOS"
  s.homepage     = "https://github.com/callstats-io/callstats-ios"
  s.license      = "Apache License, Version 2.0"
  s.author       = { "Amornchai Kanokpullwad" => "zoonref@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/callstats-io/callstats-ios.git", :tag => "#{s.version}" }
  s.source_files = "Callstats/**/*.swift"
  s.dependency "GoogleWebRTC", "~> 1.0"

end
