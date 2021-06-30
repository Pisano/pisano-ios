Pod::Spec.new do |s|
  s.name                = "Pisano"
  s.version             = "0.0.2"
  s.summary             = "The Pisano iOS SDK, for integrating Pisano into your iOS application"
  s.description         = "The Pisano iOS SDK, for integrating Pisano into your iOS application The SDK supports iOS 10+."
  s.homepage            = "https://github.com/Pisano/pisano-ios"
  s.license             = "MIT"
  s.author              = { "burkaydurdu" => "burkay.durdu@pisano.com" }
  s.platform            = :ios, "10.0"
  s.swift_version       = "5.0"
  s.source              = { :git => "https://github.com/Pisano/pisano-ios.git", :tag => "#{s.version}" }
  s.preserve_paths      = 'Feedback.xcframework'
  s.vendored_frameworks = 'Feedback.xcframework'
end
