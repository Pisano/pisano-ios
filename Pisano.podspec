Pod::Spec.new do |s|
  s.name                = "Pisano"
  s.version             = "1.1.0"
  s.summary             = "The Pisano iOS SDK, for integrating Pisano into your iOS application"
  s.description         = "The Pisano iOS SDK, for integrating Pisano into your iOS application. The SDK supports iOS 15+."
  s.homepage            = "https://github.com/Pisano/pisano-ios"
  s.license             = { :type => 'MIT', :file => 'LICENSE' }
  s.author              = { "Pisano" => "mustafa.tasli@pisano.com" }
  s.platform            = :ios, "15.0"
  s.swift_versions      = ["5.9", "6.0"]
  s.source              = { :git => "https://github.com/Pisano/pisano-ios.git", :tag => "#{s.version}" }
  s.preserve_paths      = 'PisanoFeedback.xcframework'
  s.vendored_frameworks = 'PisanoFeedback.xcframework'
end
