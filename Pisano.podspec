Pod::Spec.new do |s|
  s.name                = "Pisano"
  s.version             = "1.0.13"
  s.summary             = "The Pisano iOS SDK, for integrating Pisano into your iOS application"
  s.description         = "The Pisano iOS SDK, for integrating Pisano into your iOS application The SDK supports iOS 12+."
  s.homepage            = "https://github.com/Pisano/pisano-ios"
  s.license             = { :type => 'MIT', :file => 'LICENSE' }
  s.author              = { "Pisano" => "mustafa.tasli@pisano.com" }
  s.platform            = :ios, "12.0"
  s.swift_version       = "5.0"
  s.source              = { :git => "https://github.com/Pisano/pisano-ios.git", :tag => "#{s.version}" }
  s.preserve_paths      = 'Feedback.xcframework'
  s.vendored_frameworks = 'Feedback.xcframework'
end
