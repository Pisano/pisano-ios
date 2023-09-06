Pod::Spec.new do |s|
  s.name                = "Pisano"
  s.version             = "1.0.2"
  s.summary             = "The Pisano iOS SDK, for integrating Pisano into your iOS application"
  s.description         = "The Pisano iOS SDK, for integrating Pisano into your iOS application The SDK supports iOS 11+."
  s.homepage            = "https://github.com/Pisano/pisano-ios"
  s.license             = "MIT"
  s.author              = { "Pisano" => "mustafa.tasli@pisano.com" }
  s.platform            = :ios, "11.0"
  s.swift_version       = "5.0"
  s.source              = { :git => "https://github.com/Pisano/pisano-ios.git", :tag => "#{s.version}" }
  s.preserve_paths      = 'iOS SDK Native/PisanoFeedback.xcframework'
  s.vendored_frameworks = 'iOS SDK Native/PisanoFeedback.xcframework'
end
