# 📱Pisano iOS SDK 

![Pisano](https://uploads-ssl.webflow.com/5e9d7bd18a5e0bd38464b9e9/5f742e0de73aac75ef30e725_Pisano.png)

## Installation
Pisano for iOS supports iOS 10+. Xcode 12 is required to build Pisano iOS SDK.

### CocoaPods
Cocoapods 1.10 is required to install Pisano. Add the Pisano pod into your Podfile and run pod install.

```rb
 target :YourTargetName do
    pod 'Pisano'
 end
```

### Swift Package Manager
Add https://github.com/Pisano/pisano-ios as a Swift Package Repository in Xcode and follow the instructions to add Pisano as a Swift Package.

### Manual Installation

- [Download Pisano for iOS](https://pisano-engineering.s3-eu-west-1.amazonaws.com/Feedback-CC.xcframework.zip) and extract the zip.
- Drag Feedback.xcframework into your project.
- In the target settings for your app, set the Feedback.xcframework to “Embed & Sign”. This can be found in the “Frameworks, Libraries, and Embedded Content” section of the “General” tab.