Pod::Spec.new do |s|
  s.name                = "Pisano"
  s.version             = "0.2.1"
  s.summary             = "The Pisano iOS SDK, for integrating Pisano into your iOS application"
  s.description         = "The Pisano iOS SDK, for integrating Pisano into your iOS application The SDK supports iOS 10+."
  s.homepage            = "https://github.com/Pisano/pisano-ios"
  s.license             = "MIT"
  s.author              = { "kerimsahin" => "kerim.sahin@pisano.com" }
  s.platform            = :ios, "10.0"
  s.swift_version       = "5.0"
  s.source              = { :git => "https://github.com/Pisano/pisano-ios.git", :tag => "#{s.version}" }
  s.preserve_paths      = 'iOS SDK Web-Based/Feedback.xcframework'
  s.vendored_frameworks = 'iOS SDK Web-Based/Feedback.xcframework'
end