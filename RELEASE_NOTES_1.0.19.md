# Release 1.0.19 – Notes

## WebView zoom (MT-38)

- Disabled pinch zoom in the survey WebView (`scrollView` scale locked to 1.0).
- Injects viewport meta tag on page load (`user-scalable=no`, `maximum-scale=1.0`).
- Fixes inconsistent zoom behaviour on iOS without requiring per-channel CSS workarounds.

## Upgrade

| Method | How |
|--------|-----|
| **SPM** | Pin tag `1.0.19` on `https://github.com/Pisano/pisano-ios` |
| **CocoaPods** | `pod 'Pisano', '~> 1.0.19'` |
| **Manual** | Replace `PisanoFeedback.xcframework` with the one from this release |

Built from `feedback-ios` branch `MT-38`.
